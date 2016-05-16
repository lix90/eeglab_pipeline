function lix_run_merge(p)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pos = p.pre.pos;
ext = p.pre.ext;
in = p.dir.raw;
ou = p.dir.merge;
if ~exist(ou, 'dir'); mkdir(ou); end
[setname, id] = get_fileinfo(in, 'set', 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lix_matpool(4);
parfor i = 1:length(id)
	ALLEEG = []; EEG = []; CURRENTSET = 0;
    	name = strcat(id{i}, '_merge.set');
	outName = fullfile(ou, name);
	if exist(outName, 'file'); warning('files already exist'); continue; end
	fprintf('Merging subject %i/%i\n', i, numel(id));
    	tmp = dir(fullfile(in, strcat(id{i}, '*.', ext)));
	set_now = natsort({tmp.name});
	% load set
	for j = 1:length(set_now)
		switch ext
		case 'eeg'
			EEG = pop_fileio(fullfile(in, set_now{j}));
		case 'set'
			EEG = pop_loadset('filename', set_now{j}, 'filepath', in);
		end
		[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, j);
		EEG = eeg_checkset(EEG);
	end
	% merge set
	N = length(ALLEEG);
	if N > 1
		EEG = pop_mergeset(ALLEEG, 1:N, 0);
	    	EEG = eeg_checkset(EEG);
	    	[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,...
	        'overwrite','on');
	    	[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
	    	EEG = eeg_checkset(EEG);
	end
    	EEG.setname = strcat('S', int2str(i), '_merge');
    	EEG = pop_saveset(EEG, 'filename', outName);
    	ALLEEG = []; EEG = []; CURRENTSET = 0;
end