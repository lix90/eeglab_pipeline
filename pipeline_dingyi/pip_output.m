clear, clc, close all

baseDir = '~/Data/dingyi/';
inDir = fullfile(baseDir, 'spec_noRemoveWindows_1hz');
outDir = fullfile(baseDir, 'output_noRemoveWindows_1hz');

% rest, task1, task2, task3
nB = 5; % bands
nSt = 4; % states
nC = 34; % channels
nS = 9; % subjects

delta = [1 3];
theta = [4 7];
alpha = [8 13];
beta = [14 30];
gamma = [31 45];

tagStates = {'rest', 'task1', 'task2', 'task3'};
tagBands = {'delta', 'theta', 'alpha', 'beta', 'gamma'};
freqBands = {delta, theta, alpha, beta, gamma};

if ~exist(outDir, 'dir'); mkdir(outDir); end
chanlocs = load(fullfile(inDir, 'chanlocs.mat'));
% band * state * channel * participants
specdata = zeros(nB, nSt, nC, nS);
for iBand = 1:nB
    bNow = eval(tagBands{iBand});
    for iState = 1:nSt
        for iSubj = 1:nS
            if iSubj < 10
                fileName = strcat(tagStates{iState}, '_s0', num2str(iSubj), ...
                                  '_spec.mat');
            else
                fileName = strcat(tagStates{iState}, '_s', num2str(iSubj), ...
                                  '_spec.mat');
            end
            fprintf('load %s\n', fileName);
            load(fullfile(inDir, fileName));
            if size(y.freq,2)~=1
                y.freq = y.freq';
            end
            f = dsearchn(y.freq, bNow');
            tmpSpec = mean(y.spec(:, f(1):f(2)), 2);
            specdata(iBand, iState, :, iSubj) = tmpSpec;
        end
    end
end
out.info = 'band * state * channel * subject';
out.tagStates = tagStates;
out.tagBands = tagBands;
out.freqBands = freqBands;
out.specdata = specdata;
out.chanlocs = chanlocs.y;
save(fullfile(outDir, 'dingyi_specdata.mat'), 'out');
