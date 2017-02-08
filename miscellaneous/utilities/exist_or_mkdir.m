function ou = exist_or_mkdir(ou)

if ~isdir(ou)
	disp('input is not a directory')
	return
end

if ~exist(ou, 'dir') 
	mkdir(ou); 
end