function write_log(logfile, scriptname, id, index, total, content)

fid = fopen(logfile, 'a');
fprintf(fid, '\n%s > %s > %s/%i/%i > %s\n',...
        scriptname, id, index, total, content);
fclose(fid);
