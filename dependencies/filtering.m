function [EEG] = filtering(EEG, hi, lo)
% Filtering EEG, with high or low frequency parameters
% Default parameters are g.hi, g.lo

% high pass filtering
if exist('hi', 'var') && ~isempty(hi)
    EEG = pop_eegfiltnew(EEG, hi, 0);
    EEG = eeg_checkset(EEG);
end

% low pass filtering
if exist('lo', 'var') && ~isempty(lo)
    EEG = pop_eegfiltnew(EEG, 0, lo);
    EEG = eeg_checkset(EEG);
end
