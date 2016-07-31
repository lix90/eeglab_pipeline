function data = getCSDforEEGLAB(EEG, G, H)

data = CSD(single(EEG.data),G,H);
% compute CSD for <channels-by-samples-by-epochs> 3-D data matrix
data = double(data);
% final CSD data
