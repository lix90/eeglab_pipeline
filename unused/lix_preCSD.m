function [G, H] = lix_preCSD(EEG)

G = [];
H = [];

for site = 1:EEG.nbchan 
    trodes{site}=(EEG.chanlocs(site).labels);
end
trodes=trodes';

%% Get Montage for use with CSD Toolbox
Montage_64=ExtractMontage('10-5-System_Mastoids_EGI129.csd', trodes);
MapMontage(Montage_64);

%% Derive G and H!
[G,H] = GetGH(Montage_64);