function [G, H] = get_gh(EEG);

% Get channel labels
labels = {EEG.chanlocs.labels};
if size(labels, 2)~=1
    labels = labels';
end

% Get Montage for use with CSD Toolbox
Montage_64=ExtractMontage('10-5-System_Mastoids_EGI129.csd', labels);
MapMontage(Montage_64);

% Derive G and H!
[G,H] = GetGH(Montage_64);






