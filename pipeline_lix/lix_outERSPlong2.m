clear, clc, close all
inputDir = '~/data/Mood-Pain-Empathy/';
outputDir = fullfile(inputDir, 'csvERSP_rv15_final');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
load(fullfile(inputDir, 'study_rv15.mat'));

alpha = [9, 13];
beta = [14, 25];
time = [500, 1000];

%% start
times = STUDY.changrp(1).ersptimes;
nt = length(times);
freqs = STUDY.changrp(1).erspfreqs;
nf = length(freqs);
subjs = STUDY.subject';
exclud = {'chenxu', 'chenyanqiu', 'dairubiao', ...
          'xujin', 'pujianyong'};
subjs = subjs(~ismember(subjs, exclud));
ns = numel(subjs);
chanlabels = [STUDY.changrp.channels];

bands = {'alpha'};
chans = {'C3', 'Cz', 'C4', 'O1', 'Oz', 'O2'};
% chans = {'F3', 'F4'};
nc = numel(chans);
nb = numel(bands);
out.id = [];
out.chan = [];
out.band = [];
out.mood = [];
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
                out.mood = [out.mood; repmat(condition1(iv1), [nv2, 1])];
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
    filename = sprintf('longersp_%s_f%i-%i_t%i-%i.csv', ...
                       cellstrcat(chans, '-'), ...
                       min(f(:)), max(f(:)),...
                       min(t(:)), max(t(:)));
    outFile = fullfile(outputDir, filename);
    struct2csv(out, outFile);
end
