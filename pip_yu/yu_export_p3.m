%% script for exporting peak n1litude
% n1: 105-155, left and right 50ms
% p3: 450-650, left and right 100ms, p3l, p3r

%% input
chanLabels = {'FCz'};
timeRange = [450 650];
outDir = '';
half = 100;
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
samples = t(1):t(2);

% find n1 peak latency
[d1, d2] = size(erpData);
avgErp = cellfun(@(x) {squeeze(mean(x,2))}, erpData);
avgErp = mean(mean(reshape(cell2mat(avgErp),[length(erpTimes), size(erpData)]),d1),d2);
subErp = avgErp(t(1):t(2));

% compute peak latency of n1
[p3maxv, p3maxi] = lmax(subErp, FILT);

if isempty(union(p3maxv, p3maxi))
    % p3minv = max(subErp);
    p3maxi = erpTimes(samples(subErp==p3maxv));
else
    % p3minv = mean(p3minv);
    p3maxi = mean(erpTimes(samples(p3maxi)));
end

p3left_range = [p3maxi-half, p3maxi];
p3right_range = [p3maxi, p3maxi+half];
p3lt = dsearchn(erpTimes', p3left_range');
p3rt = dsearchn(erpTimes', p3right_range');

for iVar2 = 1:numel(var2) % loop through group
                          
    % prepare subject name
    groupSubj = group{iVar2};
    
    % prepare condition string
    conds = strcat(var2{iVar2}, '_', var1);
    conStr = strcat('subject,', strjoin(conds, ','));

    % prepare output filename
    tStr = strcat('t', strjoin(timeRange, '-'));
    cStr = strjoin(chanLabels, '-');
    
    % left p3
    p3lName = strcat('p3l_', cStr,'_', tStr, '_group', var2{iVar2}, '.csv');
    p3lOutName = fullfile(outDir, p3lName);
    p3lFID = fopen(p3lOutName, 'w');
    fprintf(p3lFID, [conStr, '\n']);

    % right p3
    p3rName = strcat('p3r_', cStr,'_', tStr, '_group', var2{iVar2}, '.csv');
    p3rOutName = fullfile(outDir, p3rName);
    p3rFID = fopen(p3rOutName, 'w');
    fprintf(p3rFID, [conStr, '\n']);    
    
    for iSubj = 1:numel(gSubj) % loop through subj
        fprintf(p3lFID, [gSubj{iSubj}, ',']); % write subj name
        fprintf(p3rFID, [gSubj{iSubj}, ',']);
        
        for iVar1 = 1:numel(var1) % loop through within var
            
            erpNow = erpData{iVar1, iVar2};
            
            % left p3
            p3l = mean(erpNow(p3lt(1):p3lt(2), iSubj));
            % right p3
            p3r = mean(erpNow(p3rt(1):p3rt(2), iSubj));
            
            if iVar1 < numel(var1)
                fprintf(p3lFID, [num2str(p3l), ',']);
                fprintf(p3rFID, [num2str(p3r), ','])
            elseif iVar1 == numel(var1)
                fprintf(p3lFID, [num2str(p3l), '\n']);
                fprintf(p3rFID, [num2str(p3r), '\n']);
            end
        end
    end
    fclose('all');
end
disp('DONE!')
