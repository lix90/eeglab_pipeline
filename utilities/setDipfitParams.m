function outputStruct = setDipfitParams(EEG, MODEL)

outputStruct = struct();
[tmpDir, tmpFile, tmpExt] = fileparts(EEG.chaninfo.filename);
if strcmp(MODEL, 'MNI')
    hdmfile = 'standard_vol.mat';
    mrifile = 'standard_mri.mat';
    chanfile = 'standard_1005.elc';
    if strcmpi(tmpFile, 'standard_1005')
        TRANS 	= [ 0.89768, -15.3666, 1.94762, 0.0762356, 5.50486e-05, -1.57378, 1.16808, 1.06005, 1.15403 ];
    elseif strcmpi(tmpFile, 'standard-10-05-cap385')
        TRANS 	= [ 0.0547605, -17.3653, -8.13178, 0.0755019, 0.00318357, -1.56963, 11.7138, 12.7933, 12.213 ];
    end
elseif strcmp(MODEL, 'Spherical')
    hdmfile = 'standard_BESA.mat';
    mrifile = 'avg152t1.mat';
    chanfile = 'standard-10-5-cap385.elp';
    if strcmpi(tmpFile, 'standard_1005')
        TRANS 	= [ -0.254232, 0, -8.4081, 0, 0.00272526, 0, 8.59463, -10.9643, 10.4963 ];
    elseif strcmpi(tmpFile, 'standard-10-05-cap385')
        TRANS 	= [ 13.4299, 0.746361, -0.654923, 0.000878113, -0.0818352, 0.0023747, 0.852832, 0.941595, 0.85887 ];
    end
end
    outputStruct.hdmfileDir = dirname(which(hdmfile));
    outputStruct.mrifileDir = dirname(which(mrifile));
    outputStruct.chanfileDir = dirname(which(chanfile));
    outputStruct.TRANS = TRANS;