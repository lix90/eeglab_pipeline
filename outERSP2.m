function out = outERSP2(STUDY, trange, freq, chan)
% use for STUDY struct array with erspdata in it

% check if erspdata exist
% if isempty(STUDY.changrp.erspdata)

out = struct();

f = freq;
c = chan;
nc = numel(c);

times = STUDY.changrp(1).ersptimes;
nt = length(times);
freqs = STUDY.changrp(1).erspfreqs;
nf = length(freqs);
subjs = STUDY.subject';
ns = numel(subjs);
chans = [STUDY.changrp.channels];

ci = find(ismember(chans, c));

designType = checkDesignType(STUDY);

nt = size(trange,2);


switch designType
  case 1
    for iT = 1:nt
        t = trange(:, iT);
        f1 = find(freqs>=f(1), 1);
        f2 = find(freqs<=f(2), 1, 'last');
        t1 = find(times>=t(1), 1);
        t2 = find(times<=t(2), 1, 'last');
        % for one way repeated measures
        out.id = subjs;
        conditions = STUDY.design.variable(1).value;
        nv = numel(conditions);
        ersp = nan(nc, ns, nv);
        for ic = 1:nc
            tmpersp = STUDY.changrp(ci).erspdata;
            for iv1 = 1:nv
                tmp2 = tmpersp{iv1};
                ersp(ic, :, iv1) = squeeze(mean(mean(tmp2(f1:f2, t1:t2, :), 1), 2));
            end
        end
        if nc == 1
            erspMean = squeeze(ersp);
        else
            erspMean = squeeze(mean(ersp,1));
        end
        for iiv1 = 1:nv
            fieldname = sprintf('ersp_%s_t%i', ...
                                conditions{iiv1}, ...
                                t(2));
            out.(fieldname) = erspMean(:,iiv1);
        end
    end
  case 2
    for iT = 1:nt
        t = trange(:, iT);
        f1 = find(freqs>=f(1), 1);
        f2 = find(freqs<=f(2), 1, 'last');
        t1 = find(times>=t(1), 1);
        t2 = find(times<=t(2), 1, 'last');
        % for two way repeated measures
        out.id = subjs;
        condition1 = STUDY.design.variable(1).value;
        condition2 = STUDY.design.variable(2).value;
        nv1 = numel(condition1);
        nv2 = numel(condition2);
        ersp = nan(nc, ns, nv1, nv2);
        for ic = 1:nc
            tmpersp = STUDY.changrp(ci).erspdata;
            for iv1 = 1:nv1
                for iv2 = 1:nv2
                    tmp2 = tmpersp{iv1, iv2};
                    ersp(ic, :, iv1, iv2) = squeeze(mean(mean(tmp2(f1:f2, t1:t2, :), 1), 2));
                end
            end
        end
        if nc == 1
            erspMean = squeeze(ersp);
        else
            erspMean = squeeze(mean(ersp, 1));
        end
        for iiv1 = 1:nv1
            for iiv2 = 1:nv2
                fieldname = sprintf('ersp_%s_%s_t%i', ...
                                    condition1{iiv1}, condition2{iiv2}, ...
                                    t(2));
                out.(fieldname) = erspMean(:, iiv1, iiv2);
            end
        end
        % case 3
        %   % for two-way mixed design
        %   continue
        % case 4
        %   % for one-way between group design
        %   continue
    end
end
%% check design type of eeglab study set
function designType = checkDesignType(STUDY)

    designType = 0;

    d = STUDY.design;
    v1 = d.variable(1).value;
    v2 = d.variable(2).value;
    p1 = d.variable(1).pairing;
    p2 = d.variable(2).pairing;

    if ~is_empty(v1) && ~is_empty(v2)
        % so two way
        % check if mixed design or repeated measures
        if strcmp(p1, 'on') && strcmp(p2, 'on')
            % so its repeated design
            designType = 2;
        elseif strcmp(p1, 'off') || strcmp(p2, 'off')
            % so it has group variable
            designType = 3;
        end
    elseif is_empty(v1) && ~is_empty(v2) && strcmp(p2, 'off')
        % so one way between
        designType = 4;
    elseif ~is_empty(v1) && strcmp(p1, 'on') && is_empty(v2)
        % so one way within
        designType = 1;
    end

%% check if empty for string array
function x = is_empty(y)

    x = false;
    if iscell(y) && isempty(char(y))
        x = true;
    elseif ischar(y) && isempty(str2mat(y))
        x = true;
    elseif isempty(y)
        x = true;
    end
