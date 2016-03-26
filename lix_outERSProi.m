inputDir = '~/data/Mood-Pain-Empathy/';
outputDir = fullfile(inputDir, 'csv_rv15');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
load(fullfile(inputDir, 'painEmpathy_rv15.mat'));

%%
time = [500 1000];
freq = [8 13];

% bands = {'theta', 'alpha', 'alpha1', 'alpha2', 'beta1', 'beta2'};
chans = {'C3', 'C1', 'Cz', 'C2', 'C4'};
nc = numel(chans);

for iC = 1:nc
    out = outERSP(STUDY, time, freq, chans(iC));
    filename = sprintf('ersp_%s_f%i-%i_t%i-%i.csv', ...
                       chans{iC}, ...
                       freq(1), freq(2), ...
                       time(1), time(2));
    outFile = fullfile(outputDir, filename);
    struct2csv(out, outFile);
end
