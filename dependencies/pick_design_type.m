function [type, var] = pick_design_type(STUDY)
% Aim: to identify what the experimental design of the STUDY is.
% output:
% <type>
% [1,1] ==> one way within subjects
% [1,2] ==> one way between subjects
% [2,1] ==> two way within subjects
% [2,3] ==> two way mixed (one between, one within) design
% [2,4] ==> two way between (both between) subjects
% <var>
% [v1, v2]
% 1 ==> within, 2 ==> between, 0 ==> empty

type = [0,0];
var = [0,0];

var_labels = {STUDY.design.variable.label};
var_pairing = {STUDY.design.variable.pairing};

var_labels_emptified = empty_empty(var_labels);
var_pairing_emptified = empty_empty(var_labels);

% one way

if length(var_labels_emptified)==1
    type(1) = 1;
    w = where_is_it(var_labels, var_labels_emptified);
    % within or between
    if strcmpi(var_pairing(w), 'off')
        var(w) = 2;
        type(2) = 2;
    elseif strcmpi(var_pairing(w), 'on')
        var(w) = 1;
        type(2) = 1;
    end

    % two way

elseif length(var_labels_emptified)==2
    type(1) = 2;
    % first var
    if strcmpi(var_pairing(1), 'off')
        var_1 = 2;
        var(1) = 2; % 1st var is between var
    elseif strcmpi(var_pairing(1), 'on')
        var_1 = 1;
        var(1) = 1; % 1st var is within var
    end
    if strcmpi(var_pairing(2), 'off')
        var_2 = 2;
        var(2) = 2;
    elseif strcmpi(var_pairing(2), 'on')
        var_2 = 1;
        var(1) = 1;
    end
    type(2) = var_1+var_2;
end
