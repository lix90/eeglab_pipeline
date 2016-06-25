function parsave(x, data)

vname = @(x) inputname(1);
s = vname(data);
save(x, s);

end