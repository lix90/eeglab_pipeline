% find index of time and frequency range

function [t, f] = lix_tfind(times, freqs, range)

try
    t = []; f = [];
    if size(times,2)~=1; times = times'; end
    if size(freqs,2)~=1; freqs = freqs'; end
    time = [range(1);range(2)];
    freq = [range(3);range(4)];
    t = dsearchn(times, time);
    f = dsearchn(freqs, freq);
catch err
    lix_disperr(err);
end
