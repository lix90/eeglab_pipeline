clear, clc, close all

inputDir = '~/data/Mood-Pain-Empathy/';
outputDir = fullfile(inputDir, 'csvERSP');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
load(fullfile(inputDir, 'yu_study_output.mat'))

% theta = [4, 7];
alpha = [8, 12];
alpha1 = [8 10];
alpha2 = [10 12];
% beta1 = [14, 20];
% beta2 = [21, 30];
% beta = [14 20];
talpha = [1000 1400];
% tbeta = [600 800];
times = STUDY.changrp(1).ersptimes;
nt = length(times);
freqs = STUDY.changrp(1).erspfreqs;
nf = length(freqs);
subjs = STUDY.subject';
ns = numel(subjs);
chanlabels = [STUDY.changrp.channels];

bands = {'alpha', 'alpha1', 'alpha2'};
chans = {'C3', 'C1', 'Cz', 'C2', 'C4', 'O1', 'Oz', 'O2'};
nc = numel(chans);
nb = numel(bands);
for iF = 1:nb
    out.id = [];
    out.chan = [];
    out.mood = [];
    out.pain = [];
    out.ersp = [];
    condition1 = STUDY.design.variable(1).value;
    condition2 = STUDY.design.variable(2).value;
    nv1 = numel(condition1);
    nv2 = numel(condition2);
    out.id = [out.id; repmat(subjs, [nc*nv1*nv2,1])];
    t = talpha;
    % if iF==1
    %     t = talpha;
    % elseif iF==2
    %     t = talpha1;
    % else
    %     t = talpha2;
    % end
    f = eval(bands{iF});
    f1 = find(freqs>=f(1), 1);
    f2 = find(freqs<=f(2), 1, 'last');
    t1 = find(times>=t(1), 1);
    t2 = find(times<=t(2), 1, 'last');
    % for two way repeated measures
    for ic = 1:nc
        ci = find(ismember(chanlabels, chans(ic)));
        out.chan = [out.chan; repmat(chans(ic), [nv1*nv2*ns,1])];
        tmpersp = STUDY.changrp(ci).erspdata;
        for iv1 = 1:nv1
            out.mood = [out.mood; repmat(condition1(iv1), [nv2*ns,1])];
            for iv2 = 1:nv2
                out.pain = [out.pain; repmat(condition2(iv2), [ns, 1])];
                tmp2 = tmpersp{iv1, iv2};
                tmp2 = squeeze(mean(mean(tmp2(f1:f2, t1:t2, :), 1), 2));
                if size(tmp2,2)~=1
                    tmp2 = tmp2';
                end
                out.ersp = [out.ersp; tmp2];
            end
        end
    end
    filename = sprintf('longersp_%s_%s_t%i-%i.csv', ...
                       cellstrcat(chans, '-'), bands{iF}, ...
                       min(t(:)), max(t(:)));
    outFile = fullfile(outputDir, filename);
    struct2csv(out, outFile);
end
