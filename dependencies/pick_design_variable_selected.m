function [vars, values] = pick_design_variable_selected(STUDY, std_num)

if ~exist('std_num', 'var')
    std_num = 1;
end

vars = {STUDY.design(std_num).variable.label};

cell = STUDY.design.cell;
var_values = {cell.value};

fn_get_values = @(vals,n) cellfun(@(x) x{n}, vals, 'uniformoutput', false);

var_1 = fn_get_values(var_values, 1);
var_2 = fn_get_values(var_values, 2);

values = {unique(var_1), unique(var_2)};
