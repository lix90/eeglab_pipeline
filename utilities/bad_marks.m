function bad_marks(params)

in = params.dir.pre;
ou = exist_or_mkdir(params.dir.bad);
[sub, id] = get_fileinfo(in, 'set', 1);
bad_chans = struct();
bad_chans.id = cell(size(id));
bad_chans.chans = cell(size(sub));
outName = fullfile(ou, 'bad_chans.mat');
for i = 1:length(sub)
	EEG = [];
	% skip if already exist
	if exist(outName, 'file'); warning('files already exist'); continue; end
	fprintf('Loading (%i/%i %s)\n', i, numel(sub), sub{i});
	EEG = pop_loadset('filename', sub{i}, 'filepath', in);
	EEG = eeg_checkset( EEG );
    bad_chans.id{i} = id{i};
    bad_chans.chans{i} = EEG.etc.badchans;
% 	if ~isempty(EEG.etc.badchans)
% 		bad_marks.badchans = EEG.etc.badchans;
% 	end
% 	if ~isempty(EEG.reject.rejmanual)
% 		bad_marks.badepoch = EEG.reject.rejmanual;
% 	end  
    EEG = [];
end
save(outName, 'bad_chans');