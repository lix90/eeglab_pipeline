function ChanOrClust = chkChanOrClust(c)


if iscellstr(c)
        ChanOrClust = 'channels';
        if numel(c)==1
            chanName = c{1};
        elseif numel(c)>=2
            chanName = cellstrcat(c, '-');
        end
        filename_prefix = ['chan', chanName];
elseif isnumeric(c)
        ChanOrClust = 'clusters';
        filename_prefix = ['clust', int2str(c)];
end
