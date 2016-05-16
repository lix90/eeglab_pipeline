%% NOTE!!!
% this script is used for output ROI of ERSP
% if your research design is repeated measure design
% let grouptag be 1 and let subGroup be the number of subjects

%----------------------
%% initiate parameters
%----------------------
clear, clc

inDIR = 'F:\emotion_regualtion\emotion_regualtion_export\ica'; % file directory
grouptag = 4 % which group do you wanna compute?
chantags = {'P2'}; % which channel do you wanna compute?
ctags = {'S_11', 'S_22', 'S_44'}; % tags of conditions of each group
subGroup = [17,16,18,17]; % number of subjects of each group
frexRange = [4 5]; % frequency range
timeRange = [2500 3500]; % time range

%-----------------
% arrange data
%-----------------

nsubs = subGroup(grouptag); % number of subjects of computed group
ncons = numel(ctags); % number of conditions
nchan = numel(chantags); % number of channels used

pos = cell(1,ncons);
for i = 1:ncons
    pos{i} = {['design5*_',int2str(grouptag), '_', ctags{i}, '.datersp']};
end

groupERSP = zeros(100, 200, nchan, nsubs, ncons);
if nchan==1
    groupERSP = squeeze(groupERSP);
end
subname = cell(1,nsubs);
for c = 1:ncons
    fprintf('loop condition %i =====> \n', c)
    tmp = dir([inDIR, filesep, pos{c}{:}]);
    filename = sort({tmp.name});
    if c == 1
        for f = 1:length(filename)
        ind = strfind(filename{f}, '_');
        subname{f} = filename{f}(ind(1)+1:ind(2)-1);
        end
    end
    for s = 1:nsubs
        fprintf('loop subject %i\n', s)
        data = importdata([inDIR, filesep, filename{s}]);
        if nchan == 1
            fprintf('channel\n')
            ichan = find(strcmpi(data.chanlabels, chantags));
            namechan = ['data.chan', int2str(ichan), '_ersp'];
            groupERSP(:,:,s,c) = eval(namechan);
        elseif nchan > 1
            for e = 1:nchan
                ichan = find(strcmpi(data.chanlabels, chantags(e)));
                namechan = ['data.chan', int2str(ichan), '_ersp'];
                groupERSP(:,:,e,s,c) = eval(namechan);
            end
            groupERSP = squeeze(mean(groupERSP, 3));
        end
        fprintf('group ERSP\n')
    end
end
%----------------
% output data
%----------------

times = data.times; freqs = data.freqs;
outputDIR = fullfile(inDIR, 'output');
if ~exist(outputDIR, 'dir'); mkdir(outputDIR); end
save([outputDIR, filesep, 'ERSP_G', int2str(grouptag), '_', strcat(chantags{:})], 'groupERSP', 'times', 'freqs');

% subject list save if necessary
fprintf('write subname list\n');
outsubName = [outputDIR, filesep, 'SubName_G',int2str(grouptag),'.txt'];

[nrows,ncols] = size(subname);
fid = fopen(outsubName, 'w');
for row = 1:nrows
    fprintf(fid, '%s\t\n', subname{row,:});
end
fclose(fid);

%--------------
% subset data
%--------------
% frexRange = [4 5]; % frequency range
% timeRange = [2500 3500]; % time range

ouDIR = outputDIR; % output file directory
if ~exist(ouDIR, 'dir'); mkdir(ouDIR); end

% find frequency and time index
if size(times,2)~=1; times = times'; end
if size(freqs,2)~=1; freqs = freqs'; end
t = dsearchn(times, timeRange');
f = dsearchn(freqs, frexRange');

% subset data
disp('subset data');
groupERSP = groupERSP(f(1):f(2), t(1):t(2), :, :);
groupERSP = squeeze(mean(mean(groupERSP,1),2));

fprintf('write data list\n');
outName = ['G',int2str(grouptag),'_',strcat(chantags{:}),'_',...
    int2str(timeRange(1)),'-',int2str(timeRange(2)),'_',...
    int2str(frexRange(1)),'-',int2str(frexRange(2)),'.txt'];
% Write data into disk
dlmwrite([ouDIR, filesep, outName], groupERSP, 'delimiter', '\t', 'precision', '%.6f');
disp('================')
disp('====CONGRATS====')
disp('================')