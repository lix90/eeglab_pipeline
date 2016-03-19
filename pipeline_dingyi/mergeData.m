baseDir = '~/Data/dingyi/';
outputDir = fullfile(baseDir, 'output_noRemoveWindows_1hz');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tagStates = {'rest', 'task1', 'task2', 'task3'};
subj = [1:4, 6:9, 11, 13, 14, 17:21];
nSubj = numel(subj);
nChan = 34;

%% sample entropy
samEnDir = fullfile(baseDir, 'samEn_noRemoveWindows_1hz');
samEn = zeros(numel(tagStates), nChan, nSubj);
for iState = 1:numel(tagStates)
    for iSubj = 1:nSubj
        tmpSubj = subj(iSubj);
        if tmpSubj<10
            filename = sprintf('%s_s0%i_samEn.mat', ...
                               tagStates{iState}, tmpSubj);
        else
            filename = sprintf('%s_s%i_samEn.mat', ...
                               tagStates{iState}, tmpSubj);
        end
        load(fullfile(samEnDir, filename));
        tmp = out.samEn;
        samEn(iState, :, iSubj) = tmp;
    end
end
sampleEn.tagStates = tagStates;
sampleEn.subj = subj;
sampleEn.data = samEn;
save(fullfile(outputDir, 'samEn.mat'), 'sampleEn');

%% relative power
relPowDir = fullfile(baseDir, 'pwelch_noRemoveWindows_1hz');
AbsPow = zeros(numel(tagStates), 8, nChan, nSubj);
RelPow = zeros(numel(tagStates), 8, nChan, nSubj);
DA = zeros(numel(tagStates), nChan, nSubj);
DTAT = zeros(numel(tagStates), nChan, nSubj);
DTAB = zeros(numel(tagStates), nChan, nSubj);
for iState = 1:numel(tagStates)
    for iSubj = 1:nSubj
        tmpSubj = subj(iSubj);
        if tmpSubj<10
            filename = sprintf('%s_s0%i_pwelch.mat', ...
                               tagStates{iState}, tmpSubj);
        else
            filename = sprintf('%s_s%i_pwelch.mat', ...
                               tagStates{iState}, tmpSubj);
        end
        load(fullfile(relPowDir, filename));
        AbsPow(iState, :, :, iSubj) = cell2mat(out.AbsPower);
        RelPow(iState, :, :, iSubj) = cell2mat(out.RelPower);
        DA(iState, :, iSubj) = out.DA;
        DTAT(iState, :, iSubj) = out.DTAT;
        DTAB(iState, :, iSubj) = out.DTAB;
    end
end
Pow.tagBands = out.Info;
Pow.Bands = out.Bands;
Pow.tagStates = tagStates;
Pow.subj = subj;
Pow.Param = out.Param;
Pow.Abs = AbsPow;
Pow.Rel = RelPow;
Pow.DA = DA;
Pow.DTAT = DTAT;
Pow.DTAB = DTAB;
save(fullfile(outputDir, 'Pow.mat'), 'Pow');
