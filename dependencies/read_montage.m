function [chanlocs, chanlabels] = read_montage(montage_type)
%
% Montage types supported:
%
% ----
% EGI:
% ----
% 'GSN-HydroCel-65v1_0.sfp'
% 'GSN-HydroCel-64v1_0.sfp'
% ...

locsfile = which(montage_type);

[eloc, labels, theta, radius, indices] = readlocs(locsfile);

if nargout == 1
    chanlocs = eloc;
elseif nargout == 2
    chanlocs = eloc;
    chanlabels = labels;
end
