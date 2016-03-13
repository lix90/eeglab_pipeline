function lix_run_epoch(params)

% procedure 2:
% 	high-pass filtering	
%	change event name
% 	epoch
%	baseline correction
%	auto bad epoch identification

%%
% directory setting
% =================
inDIR = params.prepareDIR; % file directory
ouDIR = params.epochDIR; % output file directory
if ~exist(ouDIR, 'dir'); mkdir(ouDIR); end

%---------------------
% parameters setting
%---------------------

epochTime 		= params.epochTime; % epoch time range
baseCorrect 	= params.baseCorrect; % true | false, need baseline correction?
baseline 		= params.baseline; % [] represents whole epoch data, baseline time range
eegthresh 		= params.eegthresh;
jointprob 		= params.jointprob; % for example: [6, 3]
rejkurt 		= params.rejkurt; % for example: [6, 3]
rejtrend 	 	= params.rejtrend;
rightRESP		= params.rightRESP;


tmp = dir([inDIR, filesep, '*.set']); 
sub = natsort({tmp.name});

ALLEEG = []; EEG = [];

isOpen = matlabpool('size');
if isOpen > 0
	matlabpool close force;
	matlabpool open 4;
elseif isOpen == 0
	matlabpool open 4;
end

parfor i = 1:length(sub)
	n = length(int2str(i));
	outName = [ouDIR, filesep, sub{i}(1:n+1), '_epoch.set'];
	if exist(outName, 'file'); warning('files already exist'); continue; end
	% load set
	fprintf('Loading (%i/%i %s)\n', i, length(sub), sub{i});
	EEG = pop_loadset('filename', sub{i}, 'filepath', inDIR);
	[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
	EEG = eeg_checkset( EEG );
	% badChans = EEG.etc.noiseDetection.reference.interpolatedChannels.all;
	% % EEG = pop_select(EEG,'nochannel', badChans);
	% EEG.badChans = badChans;
	% EEG.etc = []; 

	% epoch
    if chanEvents
    	toEvents2 = unique(toEvents);
        EEG = pop_epoch(EEG, toEvents2, epochTime);
    else
    	fromEvents2 = unique(fromEvents);
        EEG = pop_epoch(EEG, fromEvents2, epochTime);
    end
	EEG = eeg_checkset(EEG);
	% baseline correction
	if baseCorrect
		EEG = pop_rmbase(EEG, baseline);
	else
		disp('skip baseline correction')
	end
	EEG = eeg_checkset(EEG);

	% automatic identify bad epoch
	if ~isempty(eegthresh)
		EEG = pop_eegthresh(EEG, 1, 1:EEG.nbchan, eegthresh(1), eegthresh(2), EEG.xmin, EEG.xmax, 0, 0);
	end
	if ~isempty(jointprob)
		EEG = pop_jointprob(EEG, 1, 1:EEG.nbchan, jointprob(1), jointprob(2), 0, 0);
	end
	if ~isempty(rejtrend)
		EEG = pop_rejtrend(EEG, 1, 1:EEG.nbchan, EEG.pnts, rejtrend(1), rejtrend(2), 0, 0, 0);
	end
	if ~isempty(rejkurt)
		EEG = pop_rejkurt(EEG, 1, 1:EEG.nbchan, rejkurt(1), rejkurt(2), 0, 0);
	end

	% EEG = pop_select(EEG,'notrial', union(find(EEG.reject.rejglobal), rej));
	% EEG = eeg_checkset(EEG);
	
	EEG = eeg_checkset(EEG);
	% save set
	EEG.setname = [EEG.setname, '_epoch'];
	% save(outName, 'EEG', '-mat', '-v7.3');
	filename = [sub{i}(1:n+1), '_epoch.set'];
    EEG = pop_saveset(EEG, 'filename', filename, 'filepath', ouDIR);
	% ALLEEG = []; EEG = [];
end

