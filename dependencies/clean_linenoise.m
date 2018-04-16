function EEG = clean_linenoise(EEG, freqs, bandwidth)

if ~exist('bandwidth', 'var')
    bandwidth = 1;
end

if ~exist('freqs', 'var')
    freqs = [];
end

if ~isempty(freqs)
    EEG = pop_cleanline(EEG, 'Bandwidth', bandwidth, ...
        'LineFrequencies', freqs, 'PlotFigures',false);
end