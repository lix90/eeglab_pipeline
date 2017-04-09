function pos = set_subplot(nrow, ncol, outer, gap)
% Aim: to make positions to subplot.
%
% Input arguments:
%
% <nrow> number of rows
% <ncol> number of columns
% <outer> [left, top, right, bottom]
% <gap> [horizontal, vertical]
%
% Output arguments:
%
% <pos> [nrow, ncol] cell array
% containing element of [left, bottom, width, height]
%
% Example:
% nrow = 3, ncol = 2, outer = [0.1, 0.1, 0.1, 0.1], gap = [0.05, 0.05];
% pos = set_subplot(nrow, ncol, outer, gap);
%
% Author: lix <alexiangli@outlook.com>

if ~exist('outer', 'var')
    outer = [0.1, 0.1, 0.1, 0.1];  % left, top, right, bottom
end

if ~exist('gap', 'var')
    gap = [0.05, 0.05];  % horizontal, vertical
end

if length(outer) == 1
    outer = repmat(outer, [1, 4]);
end

if length(gap) == 1
    gap = repmat(gap, [1, 2]);
end

n_hor_gap = nrow - 1;
n_ver_gap = ncol - 1;
n_pos = nrow * ncol;

width = (1 - outer(1) - outer(3) - n_ver_gap * gap(2))/ncol;
height = (1 - outer(2) - outer(4) - n_hor_gap * gap(1))/nrow;

if width < gap(2) || height < gap(1)
    disp('Error: outer and gap are too big.')
    return;
end

pos = cell(nrow, ncol);

for r = 1:nrow
    for c = 1:ncol
        left = outer(1)+(c-1)*(gap(2)+width);
        bottom = outer(4)+(nrow-r)*(gap(1)+height);
        pos{r,c} = [left, bottom, width, height];
    end
end

% 0*ncol+1,      2, 3, ..., ncol
% 1*ncol+1,
% 2*ncol,
% ...
% (nrow-1)*ncol+1, ... (nrow-1)*ncol+ncol


