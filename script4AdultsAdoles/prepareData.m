indir = '';
nsubj = 40;
ncond = 3;
group = [20, 20];
nchan = 58;
ntime = 200;
nfreq = 100;

for igroup = 1:numel(group)
    tmpng = ngroup(igroup);
    if igroup == 1
        tmpsubj = 1:tmpng;
    else igroup == 2
        tmpsubj = tmpng+1:nsubj;
    end
    for iconds = 1:ncond
        outfile = zeros(nfreq, ntime, nchan, tmpng);
        outfilename = sprintf('ersp_g%s_c%s.mat');
        for isubjs = 1:tmpng
            filename = sprintf('design1_%s_%s_%s.datersp', ...
                               num2str(tmpsubj(isubjs)), ...
                               num2str(conds(iconds)), ...
                               num2str(group(igroup))).
            x = importdata(fullfile(indir, filename));
            nchan = numel(chanlabels);
            for ichan = 1:nchan
                chanersp = sprintf('chan%s_ersp', num2str(ichan));
                outfile(:,:,ichan,isubjs) = x.(chanersp);
            end
        end
        save(fullfile(indir, outfilename));
    end
end
