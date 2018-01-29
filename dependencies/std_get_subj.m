function subj = std_get_subj(STUDY, excluded)

subj = STUDY.subject;
if ~isempty(excluded)
    subj = subj(~ismember(subj, excluded));
end
