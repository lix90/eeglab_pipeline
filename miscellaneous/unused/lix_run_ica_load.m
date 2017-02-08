function lix_run_ica_load(params)

setDIR = params.appicaDIR; % dataset to which you want apply ica matrices
matDIR = params.icamatDIR; % ica matrix dataset directory
ouDIR = params.condDIR; % 
if ~exist(ouDIR, 'dir'); mkdir(ouDIR); end

threshold = params.rejthreshold;
rightRESP = params.rightRESP;

if params.changeEvents
	Events = natsort(unique(params.toEvents));
end

Time = params.epochTime;
nEvents = numel(Events);
reepoch = params.reepoch;

tmpset = dir([setDIR, filesep, '*.set']);
setName = natsort({tmpset.name});
tmpmat = dir([matDIR, filesep, '*.mat']);
matName = natsort({tmpmat.name});

if ~isequal(numel(setName), numel(matName))
	fprintf('lix_run_ica_load(): numbers of datasets must be consistent');
	return
end

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
for i = 1:numel(setName)
	% load set
	fprintf('Loading (%i/%i %s)\n', i, length(setName), setName{i});
	% load([setDIR, filesep, setName{i}], '-mat');
	EEG = pop_loadset('filename', setName{i}, 'filepath', setDIR);
	[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
	EEG = eeg_checkset( EEG );
	load([matDIR, filesep, matName{i}]);
	EEG = eeg_checkset(EEG);

%-----------------
% reject epoch
%-----------------
	
	% EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1 );
	% numRej = numel(find(EEG.reject.rejglobal));
	rejmark = lix_rejepoch(EEG, threshold);
	
	if ~isempty(rightRESP)
		rej = lix_rejwrongRESP(EEG, rightRESP); % reject wrong response (containing non-responses)
	end
	rejmarkall = union(rejmark, rej);
	percRej = (numel(rejmarkall) / EEG.trials)*100;
	EEG.percRej = percRej; 
	EEG = pop_select(EEG,'notrial', rejmarkall);
	[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'gui','off', 'overwrite', 'on'); 
	EEG = eeg_checkset(EEG);

%--------------------------------
% epoch into single condition
%--------------------------------

if reepoch; nEvents = 1; end
	for j = 1:nEvents
		n = length(int2str(i));
		if reepoch
			outName = [ouDIR, filesep, setName{i}(1:n+1), '_', Events{j}, '_epoch.set'];
		else
			outName = [ouDIR, filesep, setName{i}(1:n+1), '_allconds.set'];
		end
		% skip if already exist
		if exist(outName, 'file'); warning('files already exist'); continue; end
		if reepoch
			EEG = pop_epoch(EEG, Events(j), Time);
			[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'gui','off'); 
			EEG = eeg_checkset( EEG );
		end

		%--------------------------
		% apply ica matrices
		%--------------------------

		EEG.icaweights = ica.icaweights;
		EEG.icasphere = ica.icasphere;
		EEG.icawinv = ica.icawinv;
		EEG.icachansind = ica.icachansind;
		% EEG.icaact = (EEG.icaweights * EEG.icasphere) * EEG.data;
		EEG = eeg_checkset(EEG);
		% EEG = eeg_checkset(EEG);
		% [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, 1+j);
		% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);
		% save(outName, 'EEG', '-mat', '-v7.3');
		% filename = [setName{i}(1:n+1), '_', Events{j}, '_epoch.set'];
	    EEG = pop_saveset(EEG, 'filename', outName);
	    EEG = eeg_checkset(EEG);
		% ALLEEG = pop_delset(ALLEEG, 2);
		if reepoch
			[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1+j,'retrieve',1,'study',0); 
			EEG = eeg_checkset( EEG );
		end
	end
	ALLEEG = []; EEG = []; CURRENTSET = 0;
end

% EEG = pop_epoch( EEG, {  'Adult_Pain'  }, [-0.8         1.6]);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew','F:\\linlinlin_pain\\demo\\cond\\ss.set','gui','off'); 
% EEG = eeg_checkset( EEG );