function lix_preica

% initiating variables
filetype = 'eeg'; % 'eeg' or 'set'
% epoch information
epochTime = [ -1, 2.5 ];
eventList = { 'S 11', 'S 12', 'S 21', 'S 22', 'S 31', 'S 32' };
correctRESP = { 'S  7' };
% reject channels
rejElec = { 'VEO', 'HEOR', 'TP9', 'TP10' };

% reference strategies
REF = 'mastoids'; % mastoids or average

% ICA or not
ICAornot = 1; % 0 | 1

% Data dirs
baseDIR = '';
readDIR = [baseDIR 'raw\'];
writDIR = [baseDIR 'processed\'];
if ~exist(writDIR, 'dir'); mkdir(writDIR); end

% parameters of clean_rawdata
FlatlineCriterion = [];
Highpass = -1;
ChannelCriterion = 0.85;
LineNoiseCriterion = [];
BurstCriterion = -1;
WindowCriterion = -1;

% find file names
cd( readDIR )
switch filetype
case 'eeg'
    sublist=dir( '*.eeg' );
case 'set'
    sublist=dir( '*.set' );
end
sublist={ sublist.name };

% find elp file
elpDIR = strrep(which('standard-10-5-cap385.elp'), '\', '/');

try
	% Loop around subjects
	for iSub=1:length(sublist)
	    
	    outfilename = sprintf( '%s%s_preICA.set', writDIR, sublist{ iSub }( 1:end-4 ))
	    % outfilename=[ writDIR, sublist{iSub}(1:end-4), '_preICA.set' ]; 
	    
	    % skip if already exist
	    if exist(outfilename,'file')
	    	warning('processed file exists');
	        continue
	    end
	    
	    % read brainvision file
	    fprintf('Loading subject %i of %i\n', iSub, length( sublist ));
        switch filetype
        case 'eeg'
    	    EEG = pop_fileio(fullfile( readDIR, sublist{ iSub }));
        case 'set'
            EEG = pop_loadset('filename', sublist{iSub}, 'filepath', readDIR);
        end
        
	    % 1-Hz high-pass filtering
	    EEG = pop_eegfiltnew( EEG, [], 1, 1650, true, [], 0 );
	    EEG = eeg_checkset( EEG );

		% clean line noise
		EEG = cleanLineNoise( EEG );
		EEG = eeg_checkset( EEG );

		% downsample
		EEG = pop_resample( EEG, 256 );
		EEG = eeg_checkset( EEG );

	    % load channel locations
	    ind = lix_elecfind( EEG, {'TP9', 'TP10'} );

	    EEG = pop_chanedit(EEG, 'lookup', elpDIR,...
	    	'append',63,'changefield',{64 'labels' 'FCz'},...
	    	'lookup', elpDIR, 'setref',{'1:64' 'FCz'});
		EEG = eeg_checkset( EEG );
		EEG = pop_reref( EEG, ind,'refloc',...
			struct('labels',{'FCz'},'type',{''},...
				'theta',{0},'radius',{0.12662},...
				'X',{32.9279},'Y',{0},'Z',{78.363},...
				'sph_theta',{0},'sph_phi',{67.208},...
				'sph_radius',{85},'urchan',{64},...
				'ref',{'FCz'},'datachan',{0}));
		EEG = eeg_checkset( EEG );

		% remove channels
		EEG = pop_select( EEG,'nochannel', rejElec );
		EEG = eeg_checkset( EEG );

		% clean artifacts and bad channels

		EEG = clean_rawdata( ...
			EEG, FlatlineCriterion, Highpass, ...
			ChannelCriterion, LineNoiseCriterion, ...
			BurstCriterion, WindowCriterion );
		EEG = eeg_checkset( EEG );

		% re-reference
	    EEG = pop_reref( EEG, ind );
	    EEG = eeg_checkset( EEG );

		% epoch
		EEG = pop_epoch( EEG, eventList, epochTime );
		EEG = eeg_checkset( EEG );

	    % baseline-correct
	    EEG = pop_rmbase( EEG, [] );
	    EEG = eeg_checkset( EEG );

	    % reject bad epoch
	    EEG = pop_eegthresh( EEG, 1, 1:EEG.nbchan, -500, 500, EEG.xmin, EEG.xmax, 2, 0 );
	    EEG = pop_jointprob( EEG, 1, 1:EEG.nbchan, 6, 2, 0, 0 );
	    EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1 );
	    EEG = pop_select( EEG,'notrial', EEG.reject.rejglobal );
	    EEG = eeg_checkset( EEG );

	    % reject wrong- and non-response epoch
	    rej = lix_rejwrongRESP( EEG, correctRESP );
	    EEG = pop_select( EEG,'notrial', rej );
	    EEG = eeg_checkset( EEG );

	    EEG.setname = sprintf( '%s_preica', sublist{ iSub }( 1:end-4 ));
	    % EEG.setname = [ sublist{ iSub }, '_preica' ];
	    % save
	    EEG = pop_saveset( EEG,'filename', outfilename );
        % ALLEEG = []; EEG = [];

        % ica
        if ICAornot
        % [weights,sphere,mods] = runamica12(EEG, 'pcakeep', 45, 'ourdir', [writDIR, sublist{iSub}(1:end-4), '_ica\']);
        EEG = pop_runica(EEG, 'extended', 1, 'pca', EEG.nbchan);
        EEG.setname=[sublist{iSub}, '_ica'];
		EEG = pop_saveset(EEG,'filename', [writDIR, sublist{iSub}(1:end-4), '_ica.set']);
		end
		ALLEEG = []; EEG = [];
	end
catch err
	lix_disperr(err)
end
