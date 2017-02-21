%% Script for exporting spectrum values
% *IMPORTANT*: You should first load study.

%% Initialize variable

base_dir = '';
output_folder = 'output_spec';
chan_labels = {''}; 
freq_range = [];


%% Code begins

% prepare directory and filename
output_dir = fullfile(base_dir, output_folder);
mkdir_p(output_dir);
str_fr = strjoin(freq_range, '-');
str_ch = strjoin(chan_labels, '-');
output_fname = sprintf('spec_f%shz_%s.csv', str_fr, str_ch);
output_fname_full = fullfile(output_dir, output_fname);

% read specdata
[STUDY, specdata, specfreqs] = ...
    std_specplot(STUDY, ALLEEG, ...
                 'channels', chan_labels, ...
                 'noplot', 'no', ...
                 'plotsubjects', 'off', ...
                 'averagechan', 'on');

% specdata: [ncons * ngroups], its element: [freqs * subjects]
var = STUDY.design(1).variable(1).value;
subj = to_col_vector(STUDY.subject);

% pick freqs
idx_f = pick_freq(specfreqs, freq_range);

% prepare data
specdata_selected = [];
cons_column = [];
for i = 1:length(var)
    data_tmp = specdata{i};
    data_freq = squeeze(mean(data_tmp(idx_f(1):idx_f(2),:),1));
    specdata_selected = [specdata_selected; data_freq'];
    cons_column = [cons_column; repmat(var(i), [size(data_tmp,2), 1])];
end
header = {'subj', 'spec', 'group'};
data_write = [header; [subj, specdata_selected, cons_column]];

% write data
cell2csv(output_fname_full, data_write);

