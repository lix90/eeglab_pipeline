%% plot erp

% data preparation:
thresh = 2;
ALPHA = 0.05;

% erp data:
erps = erpData2;
erpsAvg = cellfun(@(x) {mean(x, 2)}, erps);
nErps = numel(erpsAvg);
times = erpTimes;

pinter = [];
% pvals data:
statData = {erps{1}, erps{3}, erps{5};...
            erps{2}, erps{4}, erps{6}};
[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
            std_stat(statData, 'groupstats', 'on', ...
                    'condstats', 'on', ...
                    'method', 'parametric');

% plot
if numel(NUMorNAME)>1
    chanNames = cellstrcat(NUMorNAME, ',');
elseif numel(NUMorNAME)==1
    chanNames = NUMorNAME{:};
end
TITLE = sprintf('ERPs\n%s', chanNames);
YLABEL = 'Amplitude (uV)';
XLABEL = 'Times (ms)';

erpLinewidth = 1.5;
erpLinestyle = {'-', '--', '-', '--', '-', '--'};

erpLegend = {'Adult Pain' 'Adult noPain' 'Child Pain' ...
             'Child noPain' 'Old Pain' 'Old noPain'};

erpBrewer = cbrewer('qual', 'Set1', nErps/2);
erpColor = {erpBrewer(1,:), erpBrewer(1,:), ...
            erpBrewer(2,:), erpBrewer(2,:), ...
            erpBrewer(3,:), erpBrewer(3,:)};

% erea parameters
areaColor = 'k';
areaAlpha = 0.1;

%parameters for figure and panel size
plotheight = 20;
plotwidth = 40;
subplotsx = 1; %
subplotsy = 1;   
leftedge = 5;
rightedge = 3;   
topedge = 3;
bottomedge = 3;
spacex = 1;
spacey = 1;
fontsize = 10;

% get pvals cluster
pClustInd = [];
pInter = pinter{3} < ALPHA;
pClust = bwconncomp(pInter);
if pClust.NumObjects >= 1
    pClustRetain = cellfun(@(x) {numel(x) >= thresh}, ...
        pClust.PixelIdxList);
    pClustInd = pClust.PixelIdxList(cell2mat(pClustRetain));
    nClust = numel(pClustInd);
    if nClust >= 1
        areaDraw = true;
    else
        areaDraw = false;
    end
else
    areaDraw = false;
end

% set ylim
negMax = min(min(cell2mat(erpsAvg)));
posMax = max(max(cell2mat(erpsAvg)));
YLIM = [round(negMax*1.2), round(posMax*1.2)];

% create subplot position
sub_pos = subplot_pos(plotwidth, plotheight, ...
    leftedge, rightedge, ...
    bottomedge, topedge, ...
    subplotsx, subplotsy, ...
    spacex, spacey);
 
% setting the Matlab figure
f = figure('color', 'w', 'visible', 'on');
clf(f);
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [plotwidth plotheight]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 plotwidth plotheight]);

% create axes        
ax = axes('position',sub_pos{1, 1}, ...
        'XGrid', 'off', ...
        'XMinorGrid', 'off', ...
        'FontSize', fontsize, ...
        'Layer', 'top');
hold on;

% plot significant erea
if areaDraw
   for iArea = 1:nClust 
        indNow = pClustInd{iArea};
        X = [times(indNow(1)), times(indNow(end))]; 
        Ypos = [YLIM(2), YLIM(2)];
        Yneg = [YLIM(1), YLIM(1)];
        hAreaPos = area(X, Ypos, 'facecolor', areaColor, ...
            'edgecolor', 'none');
        hChildPos = get(hAreaPos,'children');
        set(hChildPos,'FaceAlpha', areaAlpha);
        hAreaNeg = area(X, Yneg, 'facecolor', areaColor, ...
            'edgecolor', 'none');
        hChildNeg = get(hAreaNeg,'children');
        set(hChildNeg,'FaceAlpha', areaAlpha);
   end
end

% plot erp
hErp = zeros(1, nErps);
for iErp = 1:nErps
    hErp(iErp) = plot(times, erpsAvg{iErp}, ...
        'color', erpColor{iErp}, ...
        'linewidth', erpLinewidth, ...
        'linestyle', erpLinestyle{iErp});
end

% add reference line
plot(get(gca, 'xlim'), [0 0], ':k', 'linewidth', 1) % horizontal
plot([0 0], get(gca, 'ylim'), ':k', 'linewidth', 1) % vertical

% add title & labels
title(TITLE, 'fontname', 'courier');
xlabel(XLABEL);
ylabel(YLABEL);

% add legend
hLegend = legend(hErp, erpLegend, 'Location', 'SouthEastOutside');
legend boxoff

% remove top tick and right tick

% set box property to off and remove background color
% a = gca;
set(ax,'box','off','color','none')

% create new, empty axes with box but without ticks
% b = axes('Position', get(ax,'Position'),'box','on','xtick',[],'ytick',[]);

% set original axes as active
% axes(ax);

% link axes in case of zooming
% linkaxes([ax b])