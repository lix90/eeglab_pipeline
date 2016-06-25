%% line plot for spectral time series
outdir = '~/data/adolesvsadult/conditiondata/ersp/image/';
if ~exist(outdir, 'dir'); mkdir(outdir); end
theta = [5.5, 7.5];
alpha = [10.5, 12];
beta = [18, 20];
band = 'theta';
if strcmp(band, 'theta') || strcmp(band, 'beta')
    % chan = {'F3', 'Fz', 'F4', ...
    %         'FC3', 'FCz', 'FC4', ...
    %         'C3', 'Cz', 'C4', ...
    %         'CP3', 'CPz', 'CP4'};
    chan = {'Cz'};
elseif strcmp(band, 'alpha')
    chan = {'PO7', 'PO8', 'PO3', 'PO4', 'POz', ...
            'Oz', 'O1', 'O2'};
end
WIDTH = 10;
HEIGHT = 20;
LINEWIDTH = 2;
LEGEND = {'high', 'medium', 'neutral'};
YLIM = [-1, 4];
LINETYPE = {'-', ':', '--'};
for i = 1:numel(chan)
    roi = eval(band);
    f = dsearchn(freqs', roi');
    c = find(ismember(chans, chan{i}));
    dataSubset = cellfun(@(x) {squeeze(mean(x(f(1):f(2), :, c, :), 1))}, ...
                         data);
    dataSubset = cellfun(@(x) {squeeze(mean(x, 2))}, dataSubset);
    figure('color', 'w', ...
           'nextplot', 'add', ...
           'PaperUnits', 'centimeters', ...
           'PaperPositionMode', 'manual', ...
           'papersize', [WIDTH, HEIGHT], ...
           'PaperPosition', [0 0 WIDTH HEIGHT]);
    for igroup = 1:size(dataSubset, 2)
        subplot(size(dataSubset, 2), 1, igroup);
        hold on;
        for icond = 1:size(dataSubset, 1)
            h(icond, igroup) = plot(times, dataSubset{icond, igroup});
        end
    end
end
hold off;
