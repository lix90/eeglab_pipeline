function lix_run_ica2(p)

in = p.dir.ica;
ou = p.dir.ica2;
if ~exist(ou, 'dir'); mkdir(ou); end
ranknum2 = p.ica.ranknum2;
ref_type = p.pre.ref_type;
rej2 = p.rej2;
[sub, id] = get_fileinfo(in, 'set', 1);

lix_matpool(4);
parfor i = 1:numel(sub)
    EEG = [];
	name = strcat(id{i}, '_ica2.set');
	outName = fullfile(ou, name);
	if exist(outName, 'file'); warning('files already exist'); continue; end
	fprintf('Loading (%i/%i %s)\n', i, length(sub), sub{i});
	EEG = pop_loadset('filename', sub{i}, 'filepath', in);
	EEG = eeg_checkset(EEG);
	% reject based on icaact
% 	EEG = lix_rej_markbad(EEG, rej2);
	EEG = lix_rej_epoch(EEG, rej2);
	%================> ica <=================
    EEG = lix_runica(EEG, ref_type, ranknum2);  % run ica
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, 'filename', outName);
	EEG = [];
end