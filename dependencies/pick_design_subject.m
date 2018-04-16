function subjs = pick_design_subject(STUDY, from_group, is_all)
% Aim: to extract all subjects or from one group
%
% <from_group>: group tag or index, 'all'/[], all groups
% <is_all>:
%

% check from_group
if ~exist('from_group', 'var')
    from_group = [];
end

if ischar(from_group) && strcmpi(from_group, 'all')
    from_group = [];
end

if ~exist('is_all', 'var') && ~isempty(from_group)
    is_all = false;
elseif ~exist('is_all', 'var') && isempty(from_group)
    is_all = true;
end

if ~any(is_all==[1,0])
    disp('is_all must be logical array or 1/0.');
    return;
end

if is_all
    subjs = to_col_vector(STUDY.subject);
    return;
end

% check design type
[type, var] = pick_design_type(STUDY);
% if not between
if ~any(var==2)
    disp('Using all subjects as one group.');
    is_all = true;
end

% one between group
if length(find(var==2))==1

    cell = STUDY.design.cell;
    values_tmp = {cell.value};
    grps = cellfun(@(x) x{var==2}, values_tmp, 'uniformoutput', false);
    cons = cellfun(@(x) x{var~=2}, values_tmp, 'uniformoutput', false);
    cases = {cell.case};
    
    if ~iscellstr(cons)
        cons_ = cellfun(@(x) num2cellstr(x), cons);
        cons = cons_;
    end
    
    if ~iscellstr(grps)
        grps_ = cellfun(@(x) num2cellstr(x), grps);
        grps = grps_;
    end
    
    grps = grps(ismember(cons, cons(1)));
    grps_unique = unique(grps);
    cases = cases(ismember(cons, cons(1)));

    if ~isempty(from_group)
        if ischar(from_group)
            ind_group = ismember(grps, from_group);
            if ~any(ind_group)
                fprintf('\nGroup %s is not found.\n', from_group);
                return;
            end
        else isnumeric(from_group)
            if from_group > length(grps_unique)
                fprintf('\nError: The number of groups is smaller than %i.\n', ...
                        from_group);
                return;
            end
            ind_group = ismember(grps, grps_unique(from_group));
        end
    else  % empty extract all
        ind_group = [];
    end
    if isempty(ind_group)
        subjs = cases;
    else
        subjs = cases(ind_group);
    end
    subjs = to_col_vector(subjs);
else
    % TODO: support two way between subject design.
    disp('Error: Only support mixed or one way between subject design.');
    return;

end
