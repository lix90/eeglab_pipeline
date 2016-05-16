function lix_run_single(p)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
in = p.dir.ica2; % dataset to which you want apply ica matrices
ou = p.dir.ica_single; %
if ~exist(ou, 'dir'); mkdir(ou); end
epochtime = p.epoch.epochtime;
basetime = p.epoch.basetime;
changeEvent = p.epoch.changeEvent;
rejcomp = p.rej2.comp; % false;
rejepoch = p.rej2.epoch; % = false;
Ntrials = p.rej2.trials; %;
[sub, id] = get_fileinfo(in, 'set', 1);

if changeEvent
	Events = natsort(unique(p.epoch.to));
else
	Events = natsort(unique(p.epoch.from));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:numel(sub)
    	ALLEEG = []; EEG = []; CURRENTSET = 0;
	% load set
	fprintf('Loading (%i/%i %s)\n', i, length(sub), sub{i});
	EEG = pop_loadset('filename', sub{i}, 'filepath', in);
      [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
	EEG = eeg_checkset(EEG);
	if rejcomp
		EEG = lix_rej_comp(EEG);  % reject components
      	[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off', 'overwrite', 'on');
	end 
	for j = 1:numel(Events)
        	name = strcat(id{i}, '_', Events{j});
		outName = fullfile(ou, name);
		% skip if already exist
		if exist(outName, 'file'); warning('files already exist'); continue; end
		EEG = pop_epoch(EEG, Events(j), epochtime); % epoch into single condition
		[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1+j, 'gui','off'); 
		EEG = eeg_checkset( EEG );
		if rejepoch
			% automatic mark bad epoch
			EEG = lix_rej_markbad(EEG, rej);
			EEG = lix_rej_epoch(EEG, rej);
           		EEG = eeg_checkset(EEG);
        	end
		EEG.percRej = 1 - (EEG.trials / Ntrials);
		fprintf('reject ratio: %f\n', EEG.percRej);
        	EEG = pop_rmbase(EEG, basetime);
        	EEG = eeg_checkset(EEG);
        	[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1+j, ...
        		'overwrite', 'on', 'gui', 'off', 'savenew', outName);
		[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1+j, ...
			'retrieve', 1, 'study', 0); 
	end
	ALLEEG = []; EEG = []; CURRENTSET = 0;
end