clear, clc, close all
inputDir = '~/data/data-iris-out/';
outputDir = fullfile(inputDir, 'csvERSP');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
load(fullfile(inputDir, 'age_pain.mat'))

theta = [4 7];
% alpha = [9, 13];
% beta = [14, 25];
time = [0 400];

%% start
times = STUDY.changrp(1).ersptimes;
nt = length(times);
freqs = STUDY.changrp(1).erspfreqs;
nf = length(freqs);
subjs = STUDY.subject';
% exclud = {'chenxu', 'chenyanqiu', 'dairubiao', 'xujin', 'pujianyong'};
% subjs = subjs(~ismember(subjs, exclud));
ns = numel(subjs);
chanlabels = [STUDY.changrp.channels];

% bands = {'alpha'};
% bands = {'beta'};
bands = {'theta'}
% chans = {'C3', 'Cz', 'C4', 'O1', 'Oz', 'O2'};
% chans = {'F5', 'F3', 'F1', 'Fz', 'F2', 'F4', 'F6', 'AF3', 'AF4'};
chans = {'FC5', 'FC3', 'FC1', 'FCz', 'FC2', 'FC4','FC6'};
% chans = {'C5', 'C3', 'C1', 'Cz', 'C2', 'C4', 'C6'};
% chans = {'CP5', 'CP3', 'CP1', 'CPz', 'CP2', 'CP4', 'CP6'};
% chans = {'P5', 'P3', 'P1', 'Pz', 'P2', 'P4', 'P6'};
% chans = {'PO3', 'POz', 'PO4'};
% chans = {'O1', 'Oz', 'O2'};
nc = numel(chans);
nb = numel(bands);
out.id = [];
out.chan = [];
out.band = [];
out.age = [];
out.pain = [];
out.ersp = [];

for iF = 1:nb
    condition1 = STUDY.design.variable(1).value;
    condition2 = STUDY.design.variable(2).value;
    nv1 = numel(condition1);
    nv2 = numel(condition2);
    t = time;
    f = eval(bands{iF});
    f1 = find(freqs>=f(1), 1);
    f2 = find(freqs<=f(2), 1, 'last');
    t1 = find(times>=t(1), 1);
    t2 = find(times<=t(2), 1, 'last');
    out.band = [out.band; repmat(bands(iF), [ns*nc*nv1*nv2,1])];
    for iS = 1:ns
        out.id = [out.id; repmat(subjs(iS), [nc*nv1*nv2,1])];
        % for two way repeated measures
        for ic = 1:nc
            ci = find(ismember(chanlabels, chans(ic)));
            out.chan = [out.chan; repmat(chans(ic), [nv1*nv2,1])];
            tmpersp = STUDY.changrp(ci).erspdata;
            for iv1 = 1:nv1
                out.age = [out.age; repmat(condition1(iv1), [nv2, 1])];
                for iv2 = 1:nv2
                    out.pain = [out.pain; condition2(iv2)];
                    tmp2 = tmpersp{iv1, iv2};
                    tmp2 = squeeze(mean(mean(tmp2(f1:f2, t1:t2, iS), 1), 2));
                    if size(tmp2,2)~=1
                        tmp2 = tmp2';
                    end
                    out.ersp = [out.ersp; tmp2];
                end
            end
        end
    end
    filename = sprintf('longersp_%s_%s_t%i-%i.csv', ...
                       cellstrcat(bands, '-'), ...
                       cellstrcat(chans, '-'), ...
                       min(t(:)), max(t(:)));
    outFile = fullfile(outputDir, filename);
    struct2csv(out, outFile);
end
