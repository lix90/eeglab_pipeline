function outdata = pick_epoch(EEG, which_epoch, n_epochs, event_ids)
% which_epoch:
%    [] - random sample from all existing epochs (default)
%    numberic array - indexes
% n_epochs:
%    [] - all epochs
%    integer - number of epochs
%    1 - default
% event_ids:
%    [] - all (default)
%    cell array

if nargin==1
    which_epoch = [];
    n_epochs = 1;
    event_ids = [];
end

% epoched or not
if ndims(EEG.data)~=3
    disp('Error: data must be epoched.');
    return;
end

% default parameters
if ~exist('which_epoch', 'var')
    which_epoch = [];
end

if ~exist('n_epochs', 'var')
    n_epochs = 1;
end

if ~exist('event_ids', 'var')
    event_ids = [];
end

data = pick_events_data(EEG, event_ids);
ntrials = size(data, 3);

if isempty(which_epoch)
    idx = randsample(ntrials, n_epochs, false);
    outdata = data(:,:,idx);
else
    if any(which_epoch<1)
        disp('Error: which_epoch must not be smaller than 1.')
        return;
    elseif any(which_epoch>ntrials)
        disp('Error: which_epoch must not be bigger than the number of epochs.')
        return;
    else
        outdata = data(:,:,which_epochs)
    end
end
