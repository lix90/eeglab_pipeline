% export roi

%% cluster ersp
clear erspData erspTimes erspFreqs
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

outdir = '~/Big/clust_output'; % output directory
if ~exist(outdir, 'dir'); mkdir(outdir); end

typeName = 'channels';
chanName = cellstrcat(c, '-');
filename_prefix = ['chan', chanName];
Nt = numel(t);
for iT = 1:Nt
    filename = strcat(filename_prefix, ...
        '_f', int2str(f(1)), 'to', int2str(f(2)), ...
        '_t', int2str(t{iT}(1)), 'to', ...
        int2str(t{iT}(2)), '.csv');
    output_filename = fullfile(outdir, filename);
    [STUDY, erspData, erspTimes, erspFreqs] = ...
        std_erspplot(STUDY, ALLEEG, ...
        'plotsubjects', 'off', typeName, c,...
        'plotmode', 'none',...
        'subbaseline', 'on');
    range = [t{iT}, f];
    output = export_roi_chanersp(STUDY, erspData, ...
                                 erspTimes, erspFreqs, range);
    struct2csv(output, output_filename);
end
disp('done')