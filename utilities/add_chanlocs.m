function EEG = add_chanlocs(EEG, model, on_ref)

% model: 'MNI', 'Spherical'
% online_ref: [], 'FCz', ... get online reference back and retain it in data

% situations that need add channel locations
% 1. add channel first time. before run robust reference
% 2. add for standardizing channel locations

% ref_chan = get_ref_chan(ref_type);
loc_dir = get_loc_dir(model);
nchan = size(EEG.data,1);

if isempty(on_ref)
	EEG = pop_chanedit(EEG, 'lookup', loc_dir);
else
	if ~char(on_ref) % if on_ref is not string array
		disp('input of online reference must be string or empty array')
		return
	else % if on_ref is string array, then add on_ref back into channel location
		EEG = pop_chanedit(EEG, ...
						'lookup', loc_dir, ...
						'append',nchan, ...
						'changefield',{nchan+1, 'labels', on_ref}, ...
						'lookup',loc_dir,...
						'setref',{['1:',int2str(nchan+1)], on_ref});
	end
end
EEG = eeg_checkset(EEG);

%%================ functions ============
% get loc file directory
function loc_dir = get_loc_dir(model)
	
model = lower(model);
switch model
	case 'mni'
		locfile = 'standard_1005.elc';
	case 'spherical'
		locfile = 'standard-10-5-cap385.elp';
end
loc_dir = dirname(which(locfile));

% get ref_chan
% function ref_chan = get_ref_chan(ref_type)

% if ischar(ref_type) && strcmpi(ref_type, 'average')
% 		ref_chan = 'average';
% elseif iscellstr(ref_type)
% 	if numel(ref_type)>1
% 		ref_chan = cellstrcat(offline_ref, ' ');
%     else
% 		ref_chan = offline_ref{:};
%     end
% else
% 	disp('ref_type must be string or cellstr')
% 	return
% end