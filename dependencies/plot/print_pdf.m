function print_pdf(h, fn)
% TODO: more options


quality = '-r300';
format = '-dpdf';
print(h, quality, fn, format);

