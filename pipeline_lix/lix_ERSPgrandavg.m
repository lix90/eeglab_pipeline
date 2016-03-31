% theta: 5.5-7.5Hz, 500-600ms
% alpha: 10.5-12Hz, 850-950ms
% beta: 18-20Hz, 500-600ms
%% prepare input parameters
clear, clc

inputDir = '/home/lix/data/Mood-Pain-Empathy/';
outputDir = fullfile(inputDir, 'image');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
load(fullfile(inputDir, 'painEmpathy_rv15.mat'));

%%
alpha = [9 13 500 1100];
beta = [14 20 200 800];
times = STUDY.changrp(1).ersptimes;
freqs = STUDY.changrp(1).erspfreqs;
chans = [STUDY.changrp.channels];
chanlocs = STUDY.chanlocs;

fa1 = find(freqs>=alpha(1), 1);
fa2 = find(freqs<=alpha(2), 1, 'last');
fb1 = find(freqs>=beta(1), 1);
fb2 = find(freqs<=beta(2), 1, 'last');
ta1 = find(times>=alpha(3), 1);
ta2 = find(times<=alpha(4), 1, 'last');
tb1 = find(times>=beta(3), 1);
tb2 = find(times<=beta(4), 1, 'last');

% chan = {'C3', 'C1', 'Cz', 'C2', 'C4'};
% ic = find(ismember(chans, chan));
ersp = getERSP(STUDY);
s = ndims(ersp);

switch s
  case 5
    erspavg = squeeze(mean(mean(mean(ersp,3),4),5)); 
    topoAlpha = squeez(mean(mean(mean(mean(ersp(fa1:fa2,ta1:ta2,:,:,:),1),2), ...
                                 3),5));
    topoBeta = squeez(mean(mean(mean(mean(ersp(fb1:fb2,tb1:tb2,:,:,:),1),2),3),5));
  case 6
    erspavg = squeeze(mean(mean(mean(mean(ersp,3),4),5),6)); 
    topoAlpha = squeeze(mean(mean(mean(mean(mean(ersp(fa1:fa2,ta1:ta2,:,:,:,: ...
                                                      ),1),2),3),5),6));
    topoBeta = squeeze(mean(mean(mean(mean(mean(ersp(fb1:fb2,tb1:tb2,:,:,:,:),1),2),3),5),6));
end


%% plot
figure('color', 'w', 'nextplot', 'add', 'paperunits', 'normalized',...
       'papersize', [1, 0.8]);
imagepos = [0.08 0.1 0.5 0.4];
imagesclogy(times, freqs, erspavg);
set(get(gca, 'ylabel'), 'string', 'ERSP (dB)', 'fontsize', 12);
set(get(gca, 'xlabel'), 'string', 'Time (ms)', 'fontsize', 12);
set(gca, 'ydir', 'normal', ...
         'position', imagepos, ...
         'ytick', [4 8 13 20 30], ...
         'yticklabel', [4 8 13 20 30], ...
         'ylim', [3 30], ...
         'xlim', [-200 1200],...
         'clim', [-2 2],...
         'tickdir', 'in', ...
         'ticklength', [0.01 0],...
         'box', 'on');
% add title
ht = get(gca, 'title');
set(ht, 'string', 'Grand average of ERSP across central electrodes');
set(ht, 'position', [600, 32, 1], 'fontsize', 14);
alphaPos = [500 9 600 4];
rectangle('position', alphaPos);
lowerBeta1Pos = [200 13.5 600 6];
rectangle('position', lowerBeta1Pos);
cbPos = [imagepos(3)+imagepos(1)+0.02, imagepos(2), 0.01, 0.1];
hcbar = colorbar('position', cbPos, 'ytick', [-2 0 2], 'yticklabel', [-2 0 2]);

set(hleg, 'position', legPos);
if ~ishold; hold on; end
% plot beta
topohight = 0.2;
gap = 0.01;
betaPos = [imagepos(1)+imagepos(3)+gap*2+0.01, imagepos(2)+topohight+gap, ...
           topohight, topohight];
axes('position', betaPos);
hb = topoplot(topoBeta, chanlocs,...
              'maplimits', [-2 0],...
              'style', 'both', ...
              'electrodes', 'off');
% plot alpha
alphaleft = imagepos(1)+imagepos(3)+gap*2+0.01;
alphaPos = [alphaleft, imagepos(2), topohight, topohight];
axes('position', alphaPos);
ha = topoplot(topoAlpha, chanlocs, ...
              'maplimits', [-2 0], ...
              'style', 'both', ...
              'electrodes', 'off');
haCbarPos = [imagepos(1)+imagepos(3)+topohight+gap*2, imagepos(2), 0.01, 0.1];
haCbar = colorbar('position', haCbarPos);
set(haCbar, 'ytick', [-2 -1 0], ...
            'yticklabel', [-2 -1 0]);
hlines = findobj(gcf, 'type', 'line');
set(hlines, 'linewidth', 1);
% % add line
% lineBetaX = [0.61 0.74];
% lineBetaY = [0.5 0.3];
% annotation(gcf, 'line', lineBetaX, lineBetaY, 'linewidth', 1);
% lineAlphaX = [0.48 0.73];
% lineAlphaY = [0.6 0.6];
% annotation(gcf, 'line', lineAlphaX, lineAlphaY, 'linewidth', 1);

% set(gca, 'position', )
% save image
outName = sprintf('grandavg_central');
print(gcf, '-djpeg', '-cmyk', '-painters', ...
      fullfile(outputDir, strcat(outName, '.jpg')));
print(gcf, '-depsc', '-painters', ...
      fullfile(outputDir, strcat(outName, '.eps')));
close all
