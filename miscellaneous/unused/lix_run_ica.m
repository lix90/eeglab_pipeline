function lix_run_ica(p)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
in = p.dir.epoch;
ou = p.dir.ica;
if ~exist(ou, 'dir'); mkdir(ou); end
rej = p.rej;
% rej2 = p.ica.rej2;
ranknum1 = p.ica.ranknum1;
ref_type = p.pre.ref_type;
[sub, id] = get_fileinfo(in, 'set', 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lix_matpool(3);
parfor i = 1:length(sub)
	EEG = [];
	name = strcat(id{i}, '_ica.set');
	outName = fullfile(ou, name);
% skip if already exist
	if exist(outName, 'file'); warning('files already exist'); continue; end
	fprintf('Loading (%i/%i %s)\n', i, numel(sub), sub{i});
	EEG = pop_loadset('filename', sub{i}, 'filepath', in);
	EEG = eeg_checkset( EEG );
%================> ica1 <=================
% % reject based on raw data
	EEG = lix_rej_markbad(EEG, rej); % automatic identify bad epoch
	EEG = lix_rej_epoch(EEG, rej); % reject epoch
	EEG = lix_runica(EEG, ref_type, ranknum1); % run ica
%================> ica2 <=================
% 	EEG = lix_rej_markbad(EEG, rej2);
% 	EEG = lix_rej_epoch(EEG, rej2);
%   EEG = lix_runica(EEG, ref_type, ranknum2);  % run ica
	EEG.setname = [EEG.setname, '_ica'];
    	EEG = pop_saveset(EEG, 'filename', outName); % save set
    	EEG = eeg_checkset( EEG ); 
    	EEG = [];
end

% [EEG.icaweights, EEG.icawinv] = amica(EEG.data(:,:));
% EEG.icasphere = eye(size(EEG.icaweights));
% [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
% eeglab redraw;
