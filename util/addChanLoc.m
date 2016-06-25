function EEG = addChanLoc(EEG, brainTemplate, onlineRef, appendOnlineRef)

switch brainTemplate
  case 'MNI'
    locFile = 'standard_1005.elc';
  case 'Spherical'
    locFile = 'standard-10-5-cap385.elp';
end
chanLocDir = which(locFile);
if ispc; chanLocDir = strrep(chanLocDir, '\', '/'); end

% add channel locations
EEG = pop_chanedit(EEG, 'lookup', chanLocDir); % add channel location
EEG = eeg_checkset(EEG);

if appendOnlineRef
    nChan = size(EEG.data, 1);
    EEG = pop_chanedit(EEG, 'append', nChan, ...
                       'changefield',{nChan+1, 'labels', onlineRef}, ...
                       'lookup', chanLocDir, ...
                       'setref',{['1:',int2str(nChan+1)], onlineRef}); % add online reference
    EEG = eeg_checkset(EEG);
    
    newChanLoc = createChanLoc(onlineRef, nChan+1);
    
    EEG = pop_reref(EEG, [], 'refloc', newChanLoc); % retain online reference data back
    EEG = eeg_checkset(EEG);
    EEG = pop_chanedit(EEG, 'lookup', chanLocDir, 'setref',{['1:', int2str(size(EEG.data, 1))] 'average'});
    EEG = eeg_checkset(EEG);
    chanlocs = pop_chancenter(EEG.chanlocs, []);
    EEG.chanlocs = chanlocs;
    EEG = eeg_checkset(EEG);
end

function newChanLoc = createChanLoc(chan, n)

    newChanLoc = struct('labels', chan,...
                    'type', [],...
                    'theta', [],...
                    'radius', [],...
                    'X', [],...
                    'Y', [],...
                    'Z', [],...
                    'sph_theta', [],...
                    'sph_phi', [],...
                    'sph_radius', [],...
                    'urchan', n,...
                    'ref', n,...
                    'datachan', {0});
end
