function EEG = add_chanloc(EEG, brain_template, online_ref, append_online_ref)    
% add channel locations & recover online reference 
% e.g. EEG = addChanLoc(EEG, 'Spherical', 'FCz', true)
    
    if ~exist('brain_template', 'var')
        brain_template = g.brain_template;
    end
    
    if ~exist('online_ref', 'var')
       online_ref = g.online_ref; 
    end
    
    if ~exist('append_online_ref', 'var')
        append_online_ref = g.append_online_ref;
    end
    
    eeglab_dir = fileparts(which('eeglab.m'));
    switch brain_template
      case 'MNI'
        chanloc_file = 'standard_1005.elc';
        chanloc_dir = fullfile(eeglab_dir, 'plugins', 'dipfit2.3', 'standard_BEM', ...
                              chanloc_file);
      case 'Spherical'
        chanloc_file = 'standard-10-5-cap385.elp';
        chanloc_dir = fullfile(eeglab_dir, 'plugins', 'dipfit2.3', 'standard_BESA', ...
                              chanloc_file);
      case 'EGI65'  % EGI 64 electrodes cap
        chanloc_file = 'EGI65.elp'; 
        chanloc_dir = which(chanloc_file);
    end

    % add channel locations
    EEG = pop_chanedit(EEG, 'lookup', chanloc_dir); % add channel location
    EEG = eeg_checkset(EEG);

    % check if online_ref exist
    if any(ismember({EEG.chanlocs.labels}, online_ref))
        append_or_not = true;
    else
        append_or_not = false;
    end
    
    if ~append_or_not && append_online_ref
            nChan = size(EEG.data, 1);
            EEG = pop_chanedit(EEG, 'append', nChan, ...
                               'changefield',{nChan+1, 'labels', online_ref}, ...
                               'lookup', chanloc_dir, ...
                               'setref',{['1:',int2str(nChan+1)], online_ref}); % add online reference
            EEG = eeg_checkset(EEG);
            new_chanloc = create_chanloc(online_ref, nChan+1);
            EEG = pop_reref(EEG, [], 'refloc', new_chanloc); % retain online reference data back
            EEG = eeg_checkset(EEG);
            EEG = pop_chanedit(EEG, 'lookup', chanloc_dir, 'setref',{['1:', int2str(size(EEG.data, 1))] 'average'});
            EEG = eeg_checkset(EEG);
            chanlocs = pop_chancenter(EEG.chanlocs, []);
            EEG.chanlocs = chanlocs;
            EEG = eeg_checkset(EEG);
    else
        disp('do not need to append online reference');
    end

function new_chanloc = create_chanloc(chan, n)

    new_chanloc = struct('labels', chan,...
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
