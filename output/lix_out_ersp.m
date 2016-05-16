%% initiate parameters
inDIR = '';
% condition tags
grouptag = 1; % which group do you wanna compute?
chantags = {'FCz'}; % which group do you wanna compute?
ctags = {'S_11', ''};
% names of subjects of each group
group.one = {};
group.two = {};
group.three = {};
group.four = {};

%% 1. arrange data
%  ===============

if grouptag == 1
    subs = group.one;
elseif grouptag == 2
    subs = group.two;
elseif grouptag == 3
    subs = group.three;
elseif grouptag == 4
    subs = group.four;
end
nsubs = numel(subs);
ncons = numel(ctags);
nchan = numel(chantags);

groupERSP = zeros(100, 200, nchan, nsubs, ncons);
if nchan==1
    groupERSP = squeeze(groupERSP);
end

for s = 1:nsubs
    for c = 1:ncons
        NAME = ['design5_', subs{s}, '_', int2str(grouptag), '_', ctags{c}, '.datersp'];
        importdata([inDIR, filesep, NAME]);
        if nchan==1
            ichan = strfind(chanlabels, chantags);
            namechan = ['chan', int2str(ichan), '_ersp'];
            groupERSP(:,:,s,c) = eval(namechan);
        elseif nchan > 1
            ichan = zeros(1,nchan);
            for e = 1:nchan
                ichan = strfind(chanlabels, chantags{e});
                namechan = ['chan', int2str(ichan), '_ersp'];
                groupERSP(:,:,e,s,c) = eval(namechan);
            end
            groupERSP = squeeze(mean(groupERSP, 3));
        end
    end
end

%% 2. subset data
%  ==============

frexRange = [300 400]; % which group do you wanna compute?
timeRange = [8 13]; % which group do you wanna compute?
ouDIR = ''; % output file directory
if ~exist(ouDIR); mkdir(ouDIR); end

% find frequency and time index
if size(times,2)~=1; times = times'; end
if size(freqs,2)~=1; freqs = freqs'; end
t = dsearchn(times, frexRange);
f = dsearchn(freqs, timeRange);

% subset data
groupERSP = groupERSP(f(1):f(2), t(1):t(2), :, :);
groupERSP = squeeze(mean(mean(groupERSP,1),2));

% save data: group_channels.mat
outName = ['G',int2str(grouptag),'_',strcat(chantags{:}),'.mat'];
save([ouDIR, filesep, outName],'groupERSP')；