%% ERP descriptive plot
% prepare data
erps = reshape(erpData2, [2, 3]);
times = erpTimes;
% plot parameters
XLIM = [-200 1500];
TITLE = {'Adult Pain' 'Adult noPain' 'Child Pain' ...
		 'Child noPain' 'Old Pain' 'Old noPain'};
TITLE = reshape(TITLE, [2, 3]);
if numel(NUMorNAME)>1
    chanNames = cellstrcat(NUMorNAME, ',');
elseif numel(NUMorNAME)==1
    chanNames = NUMorNAME{:};
end
MAINTITLE = sprintf('ERPs\n%s', chanNames);

YLABEL = 'Amplitude (uV)';
XLABEL = 'Times (ms)';
% parameters for figure and panel size
plotheight = 40;
plotwidth = 60;
subplotsx = 2;
subplotsy = 3;   
leftedge = 6;
rightedge = 3;   
topedge = 6;
bottomedge = 5;
spacex = 2;
spacey = 3;
fontsize = 8; 
% set subplots
sub_pos = subplot_pos(...
    plotwidth, plotheight,...
    leftedge, rightedge, bottomedge, topedge,...
    subplotsx, subplotsy,...
    spacex, spacey);
% sub_pos = fliplr(rot90(sub_pos, 2));
% setting the Matlab figure
f = figure('color', 'w', 'visible','on');
clf(f);
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [plotwidth plotheight]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 plotwidth plotheight]);
% set ylim
negMax = min(min(cell2mat(erps)));
posMax = max(max(cell2mat(erps)));
YLIM = [round(negMax*1.2), round(posMax*1.2)];

%loop to create axes
for i = 1:subplotsx
    for ii = 1:subplotsy
        if ishold; hold off; end
        ax = axes('position', sub_pos{i, ii}, ...
            'XGrid','off', ...
            'XMinorGrid', 'off', ...
            'FontSize', fontsize, ...
            'Box', 'on', ...
            'Layer', 'top');
% plotting
        plot(times, erps{i, ii});
        if ~ishold; hold on; end
        plot(times, mean(erps{i, ii},2), 'color', 'k', 'linewidth', 3);
        xlim(XLIM); ylim(YLIM);
        plot([0 0], get(gca, 'ylim'), ':k', 'linewidth', 1);
% set title
        title(TITLE{i, ii});
% set xtick
        if ii > 1
            set(ax,'xticklabel',[])
        end
% set ytick
        if i > 1
            set(ax,'yticklabel',[])
        end
% set ylabel
        if i == 1
            ylabel(YLABEL);
        end
% set xlabel
        if ii == 1
            xlabel(XLABEL);
        end
    end
end
mtit(MAINTITLE, ...
    'fontsize', 14, ...
    'color', 'k', ...
    'FontAngle', 'normal', ...
    'FontName', 'Courier');


% hFigure = figure('color', 'white');
% nErp = numel(erps);
% 
% for iRow = 1:rSubp
%     for iCol = 1:cSubp
%        hSubp(iRow, iCol) = subplot(rSubp, cSubp, , ...
%            'parents', hFigure);
%     
%     end
% end
% 
% 
% %%// Data
% t = 0:0.01:15*pi;
% y1 = sin(t);
% 
% %%// Plot
% colors=['r' 'g' ; 'y' 'k'];
% 
% figure,
% for k1=1:2
%     for k2=1:2
%         subplot(2,2,(k1-1)*2+k2)
%         plot(t,y1,colors(k1,k2));
%     end
% end