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
times = STUDY.changrp(1).ersptimes;
freqs = STUDY.changrp(1).erspfreqs;
chans = [STUDY.changrp.channels];
chan = {'C3', 'C1', 'Cz', 'C2', 'C4'};
ic = find(ismember(chans, chan));
ersp = getERSP(STUDY);
s = ndims(ersp);
switch s
  case 5
    erspavg = squeeze(mean(mean(mean(ersp(:,:,:,ic,:),3),4),5)); 
  case 6
    erspavg = squeeze(mean(mean(mean(mean(ersp(:,:,:,ic,:,:),3),4),5),6));
end

%% plot
imagesclogy(times, freqs, erspavg);
set(gca, 'ydir', 'normal')
% line([min(times), max(times)], [8 8], 'linestyle', ':');
% line([min(times), max(times)], [10 10], 'linestyle', ':');
% line([min(times), max(times)], [13 13], 'linestyle', ':');
% line([min(times), max(times)], [20 20], 'linestyle', ':');
% line([min(times), max(times)], [30 30], 'linestyle', ':');
upperAlphaPos1 = [400 10.2 590 3];
rectangle('position', upperAlphaPos1);
upperAlphaPos2 = [1000 10.2 400 3];
rectangle('position', upperAlphaPos2);
lowerAlphaPos1 = [600 8 390 2];
rectangle('position', lowerAlphaPos1);
lowerAlphaPos2 = [1000 8 400 2];
rectangle('position', lowerAlphaPos2);
lowerBeta1Pos = [200 13.5 600 6]
rectangle('position', lowerBeta1Pos);
upperBeta2Pos = [200 20.1 600 9.8];
rectangle('position', upperBeta2Pos);
% save image
% outName = strcat('topoERSP_', ...
%                  cellstrcat(tagBands, '-'));
% print(gcf, '-djpeg', '-cmyk', '-painters', ...
%       fullfile(outdir, strcat(outName, '.jpg')));
% print(gcf, '-depsc', '-painters', ...
%       fullfile(outdir, strcat(outName, '.eps')));
% close all
