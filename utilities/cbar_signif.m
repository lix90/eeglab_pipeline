% borrow from eeglab: std_chantopo
% colorbar for significance
% -------------------------
% ng: number of groups
% maxplot:

function cbar_signif(ng, maxplot);
% Retrieving Defaults
icadefs; % eeglab default settings

pos = get(gca, 'position');
tmpc = caxis;
fact = fastif(ng == 1, 40, 20);
tmp = axes('position', [ pos(1)+pos(3)+pos(3)/fact pos(2) pos(3)/fact pos(4) ]);
map = colormap(DEFAULT_COLORMAP);
n = size(map,1);
cols = [ceil(n/2):n]';
image([0 1],linspace(0,maxplot,length(cols)),[cols cols]);
%cbar(tmp, 0, tmpc, 5);
tick = linspace(0, maxplot, maxplot+1);
set(gca, 'ytickmode', 'manual', 'YAxisLocation', 'right', 'xtick', [], ...
         'ytick', tick, 'yticklabel', round(10.^-tick*1000)/1000);
xlabel('');
colormap(DEFAULT_COLORMAP);
