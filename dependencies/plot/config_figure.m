function h_fig = config_figure(papersize, paperposition, paperunit, bgcolor)

if ~exist('bgcolor', 'var')
    bgcolor = 'w';
end

if ~exist('paperunit', 'var')
    paperunit = 'inches';
end

h_fig = figure('color', bgcolor);
set(h_fig, 'paperposition', paperposition, ...
           'papersize', papersize, ...
           'paperunits', paperunit);
