function lix_run_prep(params)

% directory setting
inDIR = params.mergeDIR;
ouDIR = params.prepDIR;
if ~exist(ouDIR, 'dir'); mkdir(ouDIR); end

online_ref	= params.onlineref; 
unused_chan = params.unusedChans;
offline_ref = params.rerefchan;

tmp = dir([inDIR, filesep, '*.set']); 
sub = natsort({tmp.name});

%------------------------------------
% prepare elp(channel location file)
%------------------------------------

tmpdir = which('standard-10-5-cap385.elp');
tmpind = strfind(tmpdir, '\');
if ~isempty(tmpind); tmpdir(tmpind) = '/'; end
elpDIR = tmpdir;

[ALLEEG EEG ALLCOM] = eeglab;
close all;
for i = 1:length(sub)

	n = length(int2str(i)); name = sub{i}(1:n+1);
	outName = [ouDIR, filesep, name, '_prep.set']; % filename is create in a pattern like 'S1,S2,...'
	% skip if already exist
	if exist(outName, 'file'); warning('files already exist'); continue; end

	% read data
	fprintf('Loading (%i/%i %s)\n', i, length(sub), sub{i});
	EEG = pop_loadset('filename', sub{i}, 'filepath', inDIR);
	[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
	EEG = eeg_checkset( EEG );

	%--------------------------------------------------------------------------------
	% load channel location file and add back online reference channel into dataset
	%--------------------------------------------------------------------------------
	EEG = lix_reref(EEG, online_ref, offline_ref, elpDIR)
	EEG = eeg_checkset(EEG);

	%--------------------------
	% remove channels unused
	%--------------------------
	disp('remove channels unused')
	chanlocs = EEG.chanlocs;
	unused_chan_index = lix_elecfind(chanlocs, unused_chan);
	EEG = pop_select(EEG,'nochannel', unused_chan_index);
	EEG = eeg_checkset(EEG);

	%-------------------------------------
	% run Prep Pipeline
	%-------------------------------------
	PREPparams.ignoreBoundaryEvents = true;
	% PREPparams.detrendType = 'high pass';
	% % PREPparams.detrendCutoff = 1;
	% % PREPparams.lineFrequencies = [60, 120, 180, 240];
	% % params.robustDeviationThreshold = 5;
	% % params.highFrequencyNoiseThreshold = 5;
	% % params.correlationThreshold = 0.4;
	% % params.badTimeThreshold = 0.01;
	PREPparams.reportMode = 'skip'; % normal | skip | reportOnly
	% PREPparams.keepFiltered = false; % true | false
	% % params.removeInterpolatedChannels = false; w% true | false
	% PREPparams.cleanupReference = false; % true | false
	% PREPparams.meanEstimateType = 'median';
	% PREPparams.interpolationOrder = 'post-reference';
	% % params.referenceChannels = 1:64;
	% % params.evaluationChannels = 1:64;
	% % params.rereferencedChannels = 1:70;
	% % params.detrendChannels = 1:70;
	% % params.lineNoiseChannels = 1:70;

	chanlocs = EEG.chanlocs;
	if isempty(refchan)
		fprintf('lix_run_prep(): using robust average reference\n')
		PREPparams.referenceType = 'robust';
		PREPparams.detrendChannels = 1:EEG.nbchan;
		PREPparams.lineNoiseChannels = 1:EEG.nbchan;
		PREPparams.referenceChannels = 1:EEG.nbchan;
		PREPparams.evaluationChannels = 1:EEG.nbchan;
		PREPparams.rereferencedChannels = 1:EEG.nbchan;
	else
		fprintf('lix_run_prep(): using user defined reference\n')
		PREPparams.referenceType = 'specific';
		refind = lix_elecfind(chanlocs, refchan);
		wholeChannels = 1:EEG.nbchan;
		PREPparams.detrendChannels = wholeChannels;
		PREPparams.lineNoiseChannels = wholeChannels;
		partChannels = wholeChannels;
		partChannels(refind) = [];
		PREPparams.referenceChannels = refind;
		PREPparams.evaluationChannels = partChannels;
		PREPparams.rereferencedChannels = refind;
	end
	% [EEG, computationTimes] = prepPipeline(EEG, PREPparams);
	%    fprintf('Computation times (seconds):\n   %s\n', ...
	%        	getStructureString(computationTimes));

	%=======================
	% cleanLineNoise errors
	%=======================
	
	%-------------------------
	% detrend
	%-------------------------
	% PREPparams.detrendType = 'high pass';
	% PREPparams.detrendCutoff = 1;
	% [EEG, detrend] = removeTrend(EEG, PREPparams);
	% EEG.etc.noiseDetection.detrend = detrend;
	
	%----------------------------
	% performe robust reference
	%----------------------------
	% PREPparams.referenceType = 'robust';
	% PREPparams.detrendChannels = 1:EEG.nbchan;
	% PREPparams.lineNoiseChannels = 1:EEG.nbchan;
	% PREPparams.referenceChannels = 1:EEG.nbchan;
	% PREPparams.evaluationChannels = 1:EEG.nbchan;
	% PREPparams.rereferencedChannels = 1:EEG.nbchan;

    [EEG, referenceOut] = performReference(EEG, PREPparams);
    EEG.etc.noiseDetection.reference = referenceOut;
	
	% save set
	EEG.setname = [name, '_prep'];
	% save(outName, 'EEG', '-mat', '-v7.3');
	filename = [name, '_prep.set'];
    EEG = pop_saveset(EEG, 'filename', filename, 'filepath', ouDIR);
	ALLEEG = []; EEG = [];
end