function lix_run_dipole(p)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
in = p.dir.ica;
ou = p.dir.dip;
if ~exist(ou, 'dir'); mkdir(ou); end
[sub, id] = get_fileinfo(in, 'set', 1);
% online_ref = [];
% offline_ref = p.preica.offline_ref;
% id = get_prefix(sub, 1);
RV = p.dip.RV;
modeltype = p.dip.type;
switch modeltype
	case 'MNI'
		hdmfile = 'standard_vol.mat';
		mrifile = 'standard_mri.mat';
		chanfile = 'standard_1005.elc';
	case 'Spherical'
		hdmfile = 'standard_BESA.mat';
		mrifile = 'avg152t1.mat';
		chanfile = 'standard-10-5-cap385.elp';
end
hdmfile_dir = dirname(which(hdmfile));
mrifile_dir = dirname(which(mrifile));
chanfile_dir = dirname(which(chanfile));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lix_matpool(4);
parfor i = 1:length(sub)
    	EEG = [];
	% name = strcat(sub{i}(1:end-4), '_dipfit.set');
	name = strcat(id{i}, '_dipfit.set');
	outName = fullfile(ou, name);
	if exist(outName, 'file'); warning('files already exist'); continue; end
	fprintf('Loading (%i/%i %s\n)', i, numel(sub), sub{i});
	EEG = pop_loadset('filename', sub{i}, 'filepath', in);
	EEG = eeg_checkset(EEG);
	nbchan = size(EEG.data, 1);
	nbcomp = size(EEG.icaact, 1);
	EEG = pop_dipfit_settings( EEG, ...
				     'hdmfile', hdmfile_dir, ...
				     'coordformat', modeltype, ...
				     'mrifile', mrifile_dir, ...
				     'chanfile', chanfile_dir, ...
				     'chansel',[1:nbcomp] );
	EEG = pop_dipfit_gridsearch(EEG, [1:nbcomp] , ...
		 			   [-85:17:85], [-85:17:85], [0:17:85], RV);
	EEG = pop_multifit( EEG, [1:nbcomp] , ...
				'threshold', RV*100, ...
				'plotopt', {'normlen' 'on'});
	EEG = eeg_checkset( EEG );
	EEG.setname = [sub{i}(1:end-4), '_dipfit'];
	EEG = pop_saveset(EEG,'filename', outName);
    	EEG = [];
end