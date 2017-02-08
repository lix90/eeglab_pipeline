function lix_movtopo(tfdata1, tfdata2, tfdata3, t, f, chanlocs, band, clim, chan)
% make movie
% ----------
try
    figure('color', 'w');
    set(gca, 'nextplot', 'replacechildren', 'visible', 'off');
    % preallocate
    nFrames = length(t);
    mov(1:nFrames) = struct('cdata', [], 'colormap', []);
    for ind = 1:nFrames
        subplot(131);
        lix_tftopo(tfdata1, t, f, chanlocs, ...
            band, t(ind), ...
            clim, chan);
        subplot(132);
        lix_tftopo(tfdata2, t, f, chanlocs, ...
            band, t(ind), ...
            clim, chan);
        subplot(133);
        lix_tftopo(tfdata3, t, f, chanlocs, ...
            band, t(ind), ...
            clim, chan);
        mov(ind) = getframe(gcf);
        close;
    end;
    close(gcf);
    % save as AVI file, and open it using system video player
    savename = char(strcat(band, '_topo.avi'));
    movie2avi(mov, savename, 'compression','None', 'fps',10);
catch err
    lix_disperr(err);
end
%
%
% %# figure
% figure, set(gcf, 'Color','white')
% Z = peaks; surf(Z);  axis tight
% set(gca, 'nextplot','replacechildren', 'Visible','off');
%
% %# preallocate
% nFrames = 20;
% mov(1:nFrames) = struct('cdata',[], 'colormap',[]);
%
% %# create movie
% for k=1:nFrames
%    surf(sin(2*pi*k/20)*Z, Z)
%    mov(k) = getframe(gca);
% end
% close(gcf)
%
% %# save as AVI file, and open it using system video player
% movie2avi(mov, 'myPeaks1.avi', 'compression','None', 'fps',10);
% winopen('myPeaks1.avi')