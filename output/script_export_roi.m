% export roi

%% cluster ersp
clear erspData erspTimes erspFreqs
Type = 2; %1='channels'/2='clusters'
c = 9; % cluster number or channel labels
% c = {'F1', 'Fz', 'F2'};
f = [8 13]; % freq range
% t = {[400 800]};
t1 = 0:100:900;
t2 = 100:100:1000;
t = [t1; t2]';
tNew = cell(size(t, 1), 1);
for iRow = 1:size(t,1)
   tNew{iRow} = t(iRow, :); 
end
t = tNew; % time range
% change design
CONDS = {'Neg_Pain' 'Neg_noPain' 'Neu_Pain' ...
		 'Neu_noPain' 'Pos_Pain' 'Pos_noPain'};
% CONDS = {'Neg_Pain' 'Neg_noPain'};
% CONDS = {'Pos_Pain', 'Pos_noPain'};
% CONDS = {'Neu_Pain', 'Neu_noPain'};
if ~isequal(STUDY.design.variable(1).value, CONDS)
    STUDY = std_makedesign(STUDY, ALLEEG, 1, ...
                           'variable1', 'type', 'pairing1', 'on', ...
                           'values1', CONDS);
    STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');
end

outdir = '~/Big/clust_output'; % output directory
if ~exist(outdir, 'dir'); mkdir(outdir); end

switch Type
    case 1
        TypeName = 'channels';
        chanName = cellstrcat(c, '-');
        filename_prefix = ['chan', chanName];
    case 2
        TypeName = 'clusters';
        filename_prefix = ['clust', int2str(c)];
end
Nt = numel(t);
for iT = 1:Nt
    filename = strcat(filename_prefix, ...
        '_f', int2str(f(1)), 'to', int2str(f(2)), ...
        '_t', int2str(t{iT}(1)), 'to', ...
        int2str(t{iT}(2)), '.csv');
    output_filename = fullfile(outdir, filename);
    [STUDY, erspData, erspTimes, erspFreqs] = ...
        std_erspplot(STUDY, ALLEEG, ...
        'plotsubjects', 'off', TypeName, c,...
        'plotmode', 'none',...
        'subbaseline', 'on');
    range = [t{iT}, f];
    if strcmpi(TypeName, 'channels')
        output = export_roi_chanersp(STUDY, erspData, ...
            erspTimes, erspFreqs, c, range);
    elseif strcmpi(TypeName, 'clusters')
        output = export_roi_clustersp(STUDY, erspData, ...
            erspTimes, erspFreqs, c, range);
    end
    struct2csv(output, output_filename);
end
disp('done')