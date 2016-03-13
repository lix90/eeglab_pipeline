function lix_run_epoch(params, erp)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
in = params.dir.pre;
if erp
	ou = params.dir.epoch_erp;
else
	ou = params.dir.epoch;
end
if ~exist(ou, 'dir'); mkdir(ou); end

ref_type 		= params.preica.ref_type;
% offline_ref 	= params.preica.offline_ref;
from 			= params.preica.from; % cell array
stim 			= params.preica.from;
resp 			= params.preica.resp;
to 				= params.preica.to; % cell array
changeEvent 	= params.preica.changeEvent;
model 			= params.preica.model;
time 			= params.preica.time; % epoch time range

[sub, id] = get_fileinfo(in, 'set', 1);

bad_in = params.dir.bad;
bad_file = get_fileinfo(bad_in, 'mat');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lix_matpool(4);
parfor i = 1:numel(sub)
	EEG = [];
	name = strcat(id{i}, '_epoch.set');
    	% name = strcat('S', int2str(i), '_epoch.set');
	outName = fullfile(ou, name);
	if exist(outName, 'file'); warning('files already exist'); continue; end
	fprintf('epoch sebject %i/%i\n', i, numel(sub));
	EEG = pop_loadset('filename', sub{i}, 'filepath', in);
	EEG = eeg_checkset( EEG );
%     bad = load(fullfile(bad_in, bad_file{i}));
%     EEG.reject.rejmanual = bad.bad_marks.badepoch;
% 	% remove bad channels
	EEG = pop_select(EEG,'nochannel', EEG.etc.badchans);
	EEG = eeg_checkset( EEG );
	% average reference again
	EEG = re_ref(EEG, ref_type);
	% add channel location again
	% EEG = lix_add_chanlocs(EEG, model, []);
	% make events readable
	EEG = readable_event(EEG, resp, stim, changeEvent, from, to);
	% epoch
    	if changeEvent
	    	marks = unique(to);
    	else
	    	marks = unique(from);
    	end
    EEG = pop_epoch(EEG, marks, time);
	EEG = eeg_checkset(EEG);
	EEG.setname = [EEG.setname, '_epoch'];
    EEG = pop_saveset(EEG, 'filename', outName);
	EEG = [];
end