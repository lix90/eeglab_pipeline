function EEG = getback_onlineref(EEG, model, on_ref, ref_type)

if ~ischar(on_ref)
	disp('on_ref must be string');
	return
end

ref_chan = get_ref_chan(ref_type);
loc_dir = get_loc_dir(model);
ref_ind = get_ref_ind(ref_type);
nchan = size(EEG.data, 1);

EEG = pop_reref( EEG, ref_ind, ...
				'refloc', struct('labels',on_ref,...
				'type', [],...
				'theta', [],...
				'radius', [],...
				'X', [],...
				'Y', [],...
				'Z', [],...
				'sph_theta', [],...
				'sph_phi', [],...
				'sph_radius', [],...
				'urchan', nchan+1,...
				'ref', on_ref,...
				'datachan', {0}));
EEG = eeg_checkset(EEG);
EEG = pop_chanedit(EEG, 'lookup', loc_dir, 'setref',{['1:',int2str(size(EEG.data, 1))] ref_chan});

% ==========functions===========
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
function ref_chan = get_ref_chan(ref_type)

if ischar(ref_type) && strcmpi(ref_type, 'average')
		ref_chan = 'average';
elseif iscellstr(ref_type)
	if numel(ref_type)>1
		ref_chan = cellstrcat(offline_ref, ' ');
    else
		ref_chan = offline_ref{:};
    end
else
	disp('ref_type must be string or cellstr')
	return
end

function ref_ind = get_ref_ind(ref_type)

if ischar(ref_type) && strcmpi(ref_type, 'average')
	ref_ind = [];
else
	if iscellstr(ref_type)
		ref_ind = lix_elecfind(EEG.chanlocs, ref_type);
	else
		disp(['ref_type must be ' 'average' ' or cellstr array of channel name'])
		return
	end
end