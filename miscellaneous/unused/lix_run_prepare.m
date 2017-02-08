function lix_run_prepare(p, erp)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model = p.pre.model; % channel location template model
online_ref = p.pre.online_ref;
ref_type = p.pre.ref_type;
unused_chan = p.pre.unused;
ds	= p.pre.ds;
in 	= p.dir.merge;
if erp
	hp 	= p.pre.hp_erp; % true | false, need filtering?
	ou	= p.dir.pre_erp;
else
	hp = p.pre.hp;
	ou = p.dir.pre;
end
if ~exist(ou, 'dir'); mkdir(ou); end
[sub, id] = get_fileinfo(in, 'set', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lix_matpool(4);
parfor i = 1:numel(sub)
	EEG = []; PREP = []; EEGclean = [];
	% name = strcat('S', int2str(i), '_pre.set');
	name = strcat(id{i}, '_pre.set');
	outName = fullfile(ou, name);
	if exist(outName, 'file'); warning('files already exist'); continue; end
	fprintf('Merging subject %i/%i\n', i, numel(sub));
	% load set
	EEG = pop_loadset('filename', sub{i}, 'filepath', in);
	% load channel location
	EEG = add_chanlocs(EEG, model, online_ref);
    	EEG = getback_onlineref(EEG, model, online_ref, ref_type);
	EEG = add_chanlocs(EEG, model, []);
    	[EEG.chanlocs.ref] = deal('average');
    	EEG = eeg_checkset(EEG);
	% re-reference to avg
	% EEG = lix_reref(EEG, offline_ref);
	% remove channels unused
	disp('remove channels unused')
	unused_chan_index = lix_elecfind(EEG.chanlocs, unused_chan);
	EEG = pop_select(EEG,'nochannel', unused_chan_index);
	EEG = eeg_checkset(EEG);
	if ~erp
		PREP.referenceType = 'robust';
		PREP.referenceChannels = 1:EEG.nbchan;
		PREP.evaluationChannels = 1:EEG.nbchan;
		PREP.rereferencedChannels = 1:EEG.nbchan;
        	[EEGclean, referenceOut] = performReference(EEG, PREP);
       	EEG.etc.badchans = referenceOut.interpolatedChannels.all;
        	EEGclean = [];
    	end
	% downsampling
	EEG = pop_resample(EEG, ds); 
	EEG = eeg_checkset(EEG);
	% high-pass filtering
	EEG = pop_eegfiltnew(EEG, hp, []); 
	EEG = eeg_checkset(EEG);
    	EEG.setname = strcat(id{i}, '_pre.set');
    	EEG = pop_saveset(EEG, 'filename', outName);
    	EEG = [];
end