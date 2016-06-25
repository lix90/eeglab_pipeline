function outdir = dirname(indir)
	if ~isempty(strfind(indir, '\'))
		outdir = strrep(indir, '\', '/'); 
	else
		outdir = indir;
	end