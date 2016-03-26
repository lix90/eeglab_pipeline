function ersp = getERSP(STUDY)
% use for STUDY struct array with erspdata in it

% check if erspdata exist
% if isempty(STUDY.changrp.erspdata)


times = STUDY.changrp(1).ersptimes;
nt = length(times);
freqs = STUDY.changrp(1).erspfreqs;
nf = length(freqs);
subjs = STUDY.subject';
ns = numel(subjs);
chans = [STUDY.changrp.channels];
nc = numel(chans);

designType = checkDesignType(STUDY);

switch designType
  case 1
    % for one way repeated measures
    conditions = STUDY.design.variable(1).value;
    nv = numel(conditions);
    ersp = nan(nf, nt,  ns, nc, nv);
    for ic = 1:nc
        tmpersp = STUDY.changrp(ic).erspdata;
        for iv1 = 1:nv
            tmp2 = tmpersp{iv1};
            ersp(:, :, :, ic, iv1) = tmp2;
        end
    end
    
  case 2
    % for two way repeated measures
    condition1 = STUDY.design.variable(1).value;
    condition2 = STUDY.design.variable(2).value;
    nv1 = numel(condition1);
    nv2 = numel(condition2);
    ersp = nan(nf, nt, ns, nc, nv1, nv2);
    for ic = 1:nc
        tmpersp = STUDY.changrp(ic).erspdata;
        for iv1 = 1:nv1
            for iv2 = 1:nv2
                tmp2 = tmpersp{iv1, iv2};
                ersp(:, :, :, ic, iv1, iv2) = tmp2;
            end
        end
    end
    % case 3
    %   % for two-way mixed design
    %   continue
    % case 4
    %   % for one-way between group design
    %   continue
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



