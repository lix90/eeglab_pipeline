function EEG = run_ica(EEG, isavg, chanind)

if ~exist('chanind', 'var')
    chanind = [];
end

if isempty(chanind)
   nc = size(EEG.data, 1); 
elseif ischar(chanind) || iscellstr(chanind)
   nc = numel(find(pick_channel_types(EEG, chanind)));
end

if isavg
    npc = nc-1;
else
    npc = nc;
end

if strcmp(computer, 'GLNXA64')
    EEG = pop_runica(EEG, 'icatype', 'binica', 'pca', npc, 'chanind', chanind);
else
    EEG = pop_runica(EEG, 'icatype', 'runica', 'pca', npc, 'chanind', chanind);
end

% iwts = pinv(wts*sph);
% scaling = repmat(sqrt(mean(iwts.^2))', [1 size(wts,2)]);
% wts = wts.*scaling;

% icawinv = pinv(wts*sph);
% icasphere = sph;
% icaweights = wts;

% icawinv = EEG.icawinv;
% icasphere = EEG.icasphere;
% icaweights = EEG.icaweights;
