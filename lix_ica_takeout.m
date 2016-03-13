function lix_ica_takeout(params)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
in_set1 = params.dir.icamat;
in_set2 = params.dir.epoch;
ou = params.dir.ica_erp;
rej = params.ica.rej;
if ~exist(ou, 'dir'); mkdir(ou); end
tmp1 = dir(fullfile(in_set1, '*.mat'));
tmp2 = dir(fullfile(in_set2, '*.set'));
sub_set1 = natsort({tmp1.name});
sub_set2 = natsort({tmp2.name});
sub_set2([3 18]) = [];
id = get_prefix(sub_set2, 1);
if numel(sub_set1)~=numel(sub_set2)
	disp('two set of data are inconsistent')
	return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lix_matpool(4);
parfor i = 1:numel(sub_set1)
	EEG = [];
	outmat = struct();
% 	name = strcat('S', int2str(i), '_icaerp.set');
    name = strcat(id{i}, '_icamat.set');
	outName = fullfile(ou, name);
	if exist(outName, 'file'); warning('files already exist'); continue; end
	% EEGica = pop_loadset('filename', sub_set1{i}, 'filepath', in_set1);
	% outmat.icaweights = EEGica.icaweights;
	% outmat.icasphere = EEGica.icasphere;
	% outmat.icawinv = EEGica.icawinv;
	% outmat.icachansind = EEGica.icachansind;
	% save(outName, 'outmat');
	icamatfile = fullfile(in_set1, sub_set1{i});
	icamat = load(icamatfile);
	EEG = pop_loadset('filename', sub_set2{i}, 'filepath', in_set2);
	EEG.icaweights = icamat.outmat.icaweights;
	EEG.icasphere = icamat.outmat.icasphere;
	EEG.icawinv = icamat.outmat.icawinv;
	EEG.icachansind = icamat.outmat.icachansind;
	EEG = eeg_checkset(EEG);
	EEG = lix_rej_markbad(EEG, rej); % automatic identify bad epoch
	EEG = lix_rej_epoch(EEG, rej); % reject epoch
% 	EEG.setname = strcat('S', int2str(i), '_add_icamat');
    	EEG.setname = strcat(id{i}, '_add_icamat');
	EEG = pop_saveset(EEG, 'filename', outName);
	EEG = [];
end