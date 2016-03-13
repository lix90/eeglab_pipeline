function parsave(x, y)

vname = @(x) inputname(1);
s = vname(y);
save(x, s);

end