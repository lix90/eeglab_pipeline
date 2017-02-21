function [group_subjs, group_tags] = pick_study_group(STUDY)

% variable types
variable_labels = {STUDY.design.variable.label};
% variable used
variable_values = {STUDY.design.cell.value};
% which variable is `group`
group_ind = find(ismember(variable_labels, 'group'));
cond_ind = find(~ismember(variable_labels, 'group'));
% groups tags
find_groups = cellfun(@(x) x{group_ind}, variable_values, 'uniformoutput', false);
find_conds = cellfun(@(x) x{cond_ind}, variable_values, 'uniformoutput', false);
which_groups = unique(find_groups);
which_conds = unique(find_conds);
howmany_groups = length(which_groups);
howmany_conds = length(which_conds);
% study groups
study_groups = STUDY.group;
% group cases
cases_temp = {STUDY.design.cell.case};
cases_used = cases_temp(ismember(find_conds,which_conds(1)));
grp_onevar = find_groups(ismember(find_conds,which_conds(1)));

% no group variable, which_groups is empty
if is_empty(which_groups)
    group_subjs = to_col_vector(cases_used);
else
    group_subjs = cell(howmany_groups,1);
    for i = 1:howmany_groups
        group_subjs = ...
            {to_col_vector(cases_used(ismember(grp_onevar,which_groups(i))))};
    end
end

group_tags = which_groups;

function em = is_empty(x)

if iscell(x) && length(x)==1
    em = isempty(x{:});
else
    em = isempty(x);
end
