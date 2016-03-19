inDir = '~/Data/dingyi/output_noRemoveWindows_1hz/';
outDir = '~/Data/dingyi/image_noRemoveWindows_1hz/';

load(fullfile(inDir, 'Pow.mat'));
load(fullfile(inDir, 'chanlocs.mat'));
load(fullfile(inDir, 'samEn.mat'));

tagBands = Pow.tagBands(1:5);
tagStates = Pow.tagStates;

%% Relative Power
for iBand = 1:numel(tagBands)
    tmp = squeeze(mean(Pow.Rel(:, iBand, :, :), 4));
    dataplot = {squeeze(tmp(1,:)), squeeze(tmp(2,:));
                squeeze(tmp(3,:)), squeeze(tmp(4,:))};
    std_chantopo(dataplot,'chanlocs', chanlocs,...
                 'datatype', 'spec',...
                 'titles', reshape(tagStates, [2,2]));
    set(gcf, 'name', tagBands{iBand});
end

%% DA
DA = squeeze(mean(Pow.DA,3));
DAplot = {squeeze(DA(1,:)), squeeze(DA(2,:));
          squeeze(DA(3,:)), squeeze(DA(4,:))};
std_chantopo(DAplot, 'chanlocs', chanlocs, ...
             'datatype', 'spec', ...
             'title', reshape(tagStates, [2,2]));
set(gcf, 'name', 'Delta/Alpha');

%% DTAT
DTAT = squeeze(mean(Pow.DTAT,3));
DTATplot = {squeeze(DTAT(1,:)), squeeze(DTAT(2,:));
            squeeze(DTAT(3,:)), squeeze(DTAT(4,:))};
std_chantopo(DTATplot, 'chanlocs', chanlocs, ...
             'datatype', 'spec', ...
             'title', reshape(tagStates, [2,2]));
set(gcf, 'name', '(Delta+Theta)/(Alpha+Theta)');

%% DTAB
DTAB = squeeze(mean(Pow.DTAB,3));
DTABplot = {squeeze(DTAB(1,:)), squeeze(DTAB(2,:));
            squeeze(DTAB(3,:)), squeeze(DTAB(4,:))};
std_chantopo(DTABplot, 'chanlocs', chanlocs, ...
             'datatype', 'spec', ...
             'title', reshape(tagStates, [2,2]));
set(gcf, 'name', '(Delta+Theta)/(Alpha+Beta)');

%% sample entropy
SE = squeeze(mean(sampleEn.data,3));
SEplot = {squeeze(SE(1,:)), squeeze(SE(2,:));
          squeeze(SE(3,:)), squeeze(SE(4,:))};
std_chantopo(SEplot, 'chanlocs', chanlocs, ...
             'datatype', 'spec', ...
             'title', reshape(tagStates, [2,2]));
set(gcf, 'name', 'sample entropy');
