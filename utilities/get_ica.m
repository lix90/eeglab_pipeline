function get_ica(params)

in = params.dir.ica2;
ou = params.dir.icamat;
if ~exist(ou, 'dir'); mkdir(ou); end
tmp = dir(fullfile(in, '*.set'));
sub = natsort({tmp.name});
id = get_prefix(sub, 1);

for i = 1:numel(sub)
	EEG = [];
	outmat = struct();
    	name = strcat(id{i}, '_icamat.mat');
	outName = fullfile(ou, name);
	if exist(outName, 'file'); warning('files already exist'); continue; end
	EEG = pop_loadset('filename', sub{i}, 'filepath', in);
	outmat.icaweights = EEG.icaweights;
	outmat.icasphere = EEG.icasphere;
	outmat.icawinv = EEG.icawinv;
	outmat.icachansind = EEG.icachansind;
	save(outName, 'outmat');
	EEG = [];
end