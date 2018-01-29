function std_cmds = build_stdcmds(subj, cond, grp);

n = numel(subj);
std_cmds = cell(1,n);

if ~exist('cond', 'var')
    cond = [];
end

if ~exist('grp', 'var')
    grp = [];
end

if ~exist('dip', 'var')
    dip = [];
end

if isempty(cond)
    cond = cell(1,n);
   [cond{:}] = deal('');
end

if isempty(grp)
    grp = cell(1,n);
   [grp{:}] = deal(''); 
end

for i = 1:n
   std_cmds{i} = {'index', i, ...
                 'subject', subj{i}, ...
                 'condition', cond{i}, ...
                 'group', grp{i}}; 
    
end

if ~isempty(dip)
   std_cmds = {std_cmds{:}, {'inbrain', dip.inbrain, ...
                   'dipselect', dip.dipselect}}; 
end
