function true_or_false = is_avgref(refs)
% when g.offline_ref is empty or is 'avg' or 'average', then return true,
% otherwise return false.

% if ~exist('refs', 'var')
%     refs = g.offline_ref;
% end

if isempty(refs)
    true_or_false = true;
else
    true_or_false = ismember({'avg', 'average'}, refs);
end
