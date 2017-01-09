%% script for exporting peak n1litude
% n1: 105-155, left and right 50ms
% p3: 450-650, left and right 100ms, p3l, p3r

%% input
chanLabels = {'FCz'}; 
timeRange = [105 155];
outDir = '';
half = 50;
FILT = 10;
group = {{},...
         {}};

%% compute erp
[STUDY, erpData, erpTimes] = std_erpplot(STUDY, ALLEEG, ...
                                         'channels', chanLabels, ...
                                         'noplot', 'on', ...
                                         'averagechan', 'on');
var1 = STUDY.design(1).variable(1).value;
var2 = STUDY.design(1).variable(2).value;

% time index
t = dsearchn(erpTimes', timeRange');
t1 = t(1); t2 = t(2);
samples = t1:t2;

% find n1 peak latency
[d1,d2] = size(erpData);
avgErp = cellfun(@(x) {squeeze(mean(x,2))}, erpData);
avgErp = mean(mean(reshape(cell2mat(avgErp),[length(erpTimes), size(erpData)]),d1),d2);
subErp = avgErp(t1:t2);

% compute peak latency of n1
[n1minv, n1mini] = lmin(subErp, FILT);

if isempty(union(n1minv, n1mini))
    % n1minv = min(subErp);
    n1mini = erpTimes(samples(subErp==n1minv));
else
    % n1minv = mean(n1minv);
    n1mini = mean(erpTimes(samples(n1mini)));
end

n1range = [n1mini-half, n1mini+half];
n1t = dsearchn(erpTimes', n1range');

%% start output peak
for iVar2 = 1:numel(var2) % loop through group
                          
    % prepare subject name
    groupSubj = group{iVar2};
    
    % prepare condition string
    conds = strcat(var2{iVar2}, '_', var1);
    conStr = strcat('subject,', strjoin(conds, ','));

    % prepare output filename
    tStr = strcat('t', strjoin(timeRange, '-'));
    cStr = strjoin(chanLabels, '-');
    
    n1Name = strcat('n1_', cStr,'_', tStr, '_group', var2{iVar2}, '.csv');
    n1OutName = fullfile(outDir, n1Name);
    n1FID = fopen(n1OutName, 'w');
    fprintf(n1FID, [conStr, '\n']);

    for iSubj = 1:numel(gSubj) % loop through subj
        fprintf(n1FID, [gSubj{iSubj}, ',']); % write subj name
    
        for iVar1 = 1:numel(var1) % loop through within var
            
            erpNow = erpData{iVar1, iVar2};
            n1 = mean(erpNow(n1t(1):n1t(2), iSubj));
        
            if iVar1 < numel(var1)
                fprintf(n1FID, [num2str(n1), ',']);
            elseif iVar1 == numel(var1)
                fprintf(n1FID, [num2str(n1), '\n']);
            end
            
        end % within var end
    end % subj loop end
        fclose(n1FID);
end % group end
    disp('DONE!')
