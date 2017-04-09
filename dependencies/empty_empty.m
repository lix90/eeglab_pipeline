function outcell = empty_empty(incell)
% Aim: remove empty string from cellstr

empty_element_ind = cellfun(@isemptyr, incell);
outcell = incell(~empty_element_ind);
