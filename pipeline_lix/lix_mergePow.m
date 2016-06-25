%% script for computing psd and sample entropy

clear, clc, close all;
baseDir = '~/Data/moodPain_final/';
inputDir = fullfile(baseDir, 'CRBPow_rv100');
outputDir = fullfile(baseDir, 'mergePow_rv100');

v1 = {'Neg', 'Neu', 'Pos'};
v2 = {'noPain', 'Pain'};
chan = {'C5', 'C3', 'C1', 'Cz', 'C2', 'C4', 'C6', 'O1', 'Oz', 'O2'};
onIAF = false;
comptype = 'log'; % 'log'
fr = [8 13];

% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

tmp = dir(fullfile(inputDir, '*.mat'));
tmp = {tmp.name};
id = unique(strtok(tmp, '_'));
nSubj = numel(id);

tagSubj = [];
tagV1 = [];
tagV2 = [];
tagchan = [];
IAF = [];
alpha = [];
alpha1 = [];
alpha2 = [];
beta = [];

% if matlabpool('size') < poolsize
%     matlabpool('local', poolsize)
% end

for i = 1:nSubj
    fprintf('sub %i\n', i)
    tagSubj = [tagSubj; repmat(id(i), [numel(v1)*numel(v2)*numel(chan), 1])];
    % load dataset
    for iv1 = 1:numel(v1)
        tagV1 = [tagV1; repmat(v1(iv1), [numel(v2)*numel(chan), 1])];
        for iv2 = 1:numel(v2)
            tagV2 = [tagV2; repmat(v2(iv2), [numel(chan), 1])];
            filename = fullfile(inputDir, sprintf('%s_%s_%s_CBRPow.mat', ...
                                                  id{i}, v1{iv1}, v2{iv2}));
            load(filename);
            ref = CRB.spectra.ave_refspectra;
            test = CRB.spectra.ave_testspectra;
            f = CRB.spectra.f;
            % get ROI
            chanlabels = {CRB.par.chanlocs.labels};
            for ic = 1:numel(chan)
                ci = find(ismember(chanlabels, chan(ic)));
                tagchan = [tagchan; chan(ic)];
                
                refci = ref(ci, :);
                testci = test(ci, :);
                
                p = findPeak(refci, f, fr);
                fprintf('peak is %f, ', p);
                % p = 10;
                
                ia1 = find(f>=p-2, 1);
                ia = find(f>=p, 1);
                ia2 = find(f>=(p+2), 1);
                
                tmpref1 = sum(refci(ia1:ia));
                tmptest1 = sum(testci(ia1:ia));
                tmpref2 = sum(refci(ia:ia2));
                tmptest2 = sum(testci(ia:ia2));
                tmpref = sum(refci(ia1:ia2));
                tmptest = sum(testci(ia1:ia2));                
                tmpbetaRef = sum(refci(ia2:(ia2+10)));
                tmpbetaTest = sum(testci(ia2:(ia2+10)));
                if strcmp(comptype, 'log')
                    alpha = [alpha; 10*log10(tmptest/tmpref)];
                    alpha1 = [alpha1; 10*log10(tmptest1/tmpref1)];
                    alpha2 = [alpha2; 10*log10(tmptest2/tmpref2)];
                    beta = [beta; 10*log10(tmpbetaTest/tmpbetaRef)];
                elseif strcmp(comptype, 'per')
                    alpha = [alpha; 100*(tmpref-tmptest)/tmpref];
                    alpha1 = [alpha1; 100*(tmpref1-tmptest1)/tmpref1];
                    alpha2 = [alpha2; 100*(tmpref2-tmptest2)/tmpref2];
                    beta = [beta; 100*(tmpbetaRef-tmpbetaTest)/tmpbetaRef];
                end 
            end
            % merge whole data 
            ave_refspectra(:, :, i, iv1, iv2) = CRB.spectra.ave_refspectra;
            ave_testspectra(:, :, i, iv1, iv2) = CRB.spectra.ave_testspectra;
        end     
    end
end
%% power
power.param = CRB.par;
power.L = CRB.L;
power.f = f;
power.ave_alpha_int = CRB.ave_alpha_int;
power.chanlocs = CRB.par.chanlocs;
power.ave_refspectra = ave_refspectra;
power.ave_testspectra = ave_testspectra;
%% IAF
iaf.id = tagSubj;
iaf.mood = tagV1;
iaf.pain = tagV2;
iaf.IAF = IAF;
%% alpha
alphaPower.id = tagSubj;
alphaPower.mood = tagV1;
alphaPower.pain = tagV2;
alphaPower.chan = tagchan;
alphaPower.alpha = alpha;
alphaPower.alpha1 = alpha1;
alphaPower.alpha2 = alpha2;
alphaPower.beta = beta;
%% save
save(fullfile(outputDir, 'power.mat'), 'power');
% if onIAF
%     % struct2csv(iaf, fullfile(outputDir, sprintf('IAF_%s.csv', comptype)));
%     struct2csv(alphaPower, fullfile(outputDir, ...
%                                     sprintf('alpha_iaf_%s.csv', comptype)));
% else
struct2csv(alphaPower, fullfile(outputDir, sprintf('alpha_iaf.csv')));
% end

