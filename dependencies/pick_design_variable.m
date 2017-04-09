function [vars, values] = pick_design_variable(STUDY, is_all, is_unique)
% Aim: to extract the variables and the values of variables
% <is_all>:
% true/1: all variables and their values
% false/0: variables and their values selected

if ~exist('is_all', 'var')
    is_all = true;
end

if ~exist('is_unique', 'var')
    is_unique = true;
end


vars = {STUDY.design.variable.label};

if is_all

    values = {STUDY.design.variable.value};

else

    cell = STUDY.design.cell;
    var_values = {cell.value};

    fn_get_values = @(vals,n) cellfun(@(x) x{n}, vals, 'uniformoutput', false);

    var_1 = fn_get_values(var_values, 1);
    var_2 = fn_get_values(var_values, 2);

    if is_unique
        values = {unique(var_1), unique(var_2)};
    else
        values = {var_1, var_2};
    end
end
