function ngroup = pick_design_ngroup(STUDY)

[design_type, type_idx] = pick_design_type(STUDY);

if design_type(2)==1
    ngroup = 1;
    return;
end

% between & mixed design
[t, v] = pick_design_variable(STUDY);
ngroup = length(v{type_idx==2});
