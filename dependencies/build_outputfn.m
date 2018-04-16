function outfn = build_outputfn(prefix, chan, time, freq, suffix, ext)

chan_str = str_join(chan, '-');
time_str = strcat('t', str_join(time, '-'));
if isempty(freq)
    freq_str = '';
else
    freq_str = strcat('_', 'f', str_join(freq, '-'));
end

if isempty(prefix)
    prefix = '';
else
    prefix = strcat(prefix, '_');
end

if isempty(suffix)
    suffix = '';
else
    suffix = strcat('_', suffix);
end

outfn = strcat(prefix, chan_str, '_', time_str, freq_str, suffix, '.', ext);
