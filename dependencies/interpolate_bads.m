function EEG = interpolate_bads(EEG, bads, method)
% Interpolate bads channels:
% using own channlocs with 'bad' type
% or using specified channel labels
% or using channel locs files

if ~exist('method', 'var')
    method = 'spherical';
end

% using `bad` type
if nargin==1
    bad = find(pick_channel_types(EEG, 'bad'));
    if isempty(bad)
        disp(['Warning: There is no bad channel to interpolate. If there is\n ' ...
              'one, please set bad channel first or import one.']);
        return;
    end
    EEG = pop_interp(EEG, bad, method);
% specified bad channels
elseif nargin==2
    if iscell(bads) || ischar(bads)
        bad = find(pick_channel_index(EEG, bads));
        if isempty(bad)
            disp('Error: The channels you specified are not found.');
            return;
        else
            EEG = pop_interp(EEG, bad, method);
        end
    else isstruct(bads)
        EEG = pop_interp(EEG, bads, method);
    end
end
