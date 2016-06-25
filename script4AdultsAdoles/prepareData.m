indir = '~/data/adolesvsadult/conditiondata/ersp_data/';
outdir = '~/data/adolesvsadult/conditiondata/ersp/';
nsubj = 40;
ncond = 3;
group = [20, 20];
nchan = 58;
ntime = 200;
nfreq = 100;

for igroup = 1:numel(group)
    tmpng = group(igroup);
    if igroup == 1
        tmpsubj = 1:tmpng;
    else igroup == 2
        tmpsubj = tmpng+1:nsubj;
    end
    for iconds = 1:ncond
        outfile = zeros(nfreq, ntime, nchan, tmpng);
        outfilename = sprintf('ersp_g%i_c%i.mat', igroup, iconds);
        for isubjs = 1:tmpng
            filename = sprintf('design1_%i_%i_%i.datersp', ...
                               tmpsubj(isubjs), iconds, igroup);
            x = importdata(fullfile(indir, filename));
            nchan = numel(x.chanlabels);
            for ichan = 1:nchan
                chanersp = sprintf('chan%s_ersp', num2str(ichan));
                outfile(:,:,ichan,isubjs) = x.(chanersp);
            end
        end
        fprintf('save files\n');
        save(fullfile(outdir, outfilename));
    end
end
