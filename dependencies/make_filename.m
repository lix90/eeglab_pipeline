function outfilename = make_filename(arg)
% arg.outdir,
% arg.chan,
% arg.time,
% arg.freq,
% arg.prefix,
% arg.suffix


if ~isfield(arg, 'outdir')
    arg.outdir = pwd;
end

if ~isfield(arg, 'chan')
    print_err('No `chan` fieldname.');
    arg.chan = {'Channel'};
end

if ~isfield(arg, 'time')
    print_err('No `time` fieldname.');
    arg.time = [];
end

if ~isfield(arg, 'freq')
    print_err('No `freq` fieldname.');
    arg.freq = [];
end

if ~isfield(arg, 'prefix')
    arg.prefix = [];
end

if ~isfield(arg, 'suffix')
    print_err('No `suffix` fieldname.');
    return;
end


outdir = arg.outdir;
chan = arg.chan;
time = arg.time;
freq = arg.freq;
prefix = arg.prefix;
suffix = arg.suffix;

% prepare output name
time_str = str_join(time, '-');
chan_str = str_join(chan, '-');
freq_str = str_join(freq, '-');

cat_str = {prefix, chan_str, time_str, freq_str};
cat_str = cat_str(~ismember(cat_str, ''));

filename = strcat(str_join(cat_str, '_'), suffix);
outfilename = fullfile(outdir, filename);
