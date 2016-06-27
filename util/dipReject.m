function [EEG, badICs] = dipReject(EEG, brainTemplate, rvDipoleEstimate, ...
                                   rvReject, inBrain)

switch brainTemplate
  case 'Spherical'
    locFile = 'standard-10-5-cap385.elp';
    hdmfile = 'standard_BESA.mat';
    mrifile = 'avg152t1.mat';
    chanfile = 'standard-10-5-cap385.elp';
    hdmfileDir = which(hdmfile);
    mrifileDir = which(mrifile);
    chanfileDir = which(chanfile);
    locDir = which(locFile);
    if ispc
        hdmfileDir = strrep(hdmfileDir, '\', '/');
        mrifileDir = strrep(mrifileDir, '\', '/');
        chanfileDir = strrep(chanfileDir, '\', '/');
        locDir = strrep(locDir, '\', '/');
    end
  case 'MNI'
    disp('please change script by your self for MNI template');
    % TRANS = [ 13.4299, 0.746361, -0.654923, 0.000878113, -0.0818352, ...
    %           0.0023747, 0.852832, 0.941595, 0.85887 ];
    % MNI
    % locFile = 'standard_1005.elc';
    % hdmfile = 'standard_vol.mat';
    % mrifile = 'standard_mri.mat';
    % chanfile = 'standard_1005.elc';
    return
end

% dipfit
nComp = size(EEG.icaweights, 1);
nChan = size(EEG.data, 1);
EEG = pop_dipfit_settings(EEG, ...
                          'hdmfile', hdmfileDir,...
                          'coordformat', brainTemplate,...
                          'mrifile', mrifileDir,...
                          'chanfile', chanfileDir,...
                          'chansel',[1:nChan]);
EEG = pop_dipfit_gridsearch(EEG, ...
                            [1:nComp] ,...
                            [-85:17:85] ,[-85:17:85] ,[0:17:85], ...
                            rvDipoleEstimate);
EEG = eeg_checkset(EEG);
EEG = pop_multifit( EEG, [1:nComp] , ...
                    'threshold', rvDipoleEstimate*100, ...
                    'plotopt', {'normlen' 'on'});
EEG = eeg_checkset(EEG);

% identify outside dipoles and dipoles rv above xx%
selectedICs = eeg_dipselect(EEG, rvReject*100, 'inbrain', 1);
badICs = ones(1, nComp);
badICs(selectedICs) = 0;