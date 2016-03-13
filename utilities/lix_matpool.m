function lix_matpool(pool_size)

% if ~isinteger(poolsize) || poolsize <= 0 || poolsize > poolsize
% 	disp('input must be positive integer equal or smaller than 4')
% 	return
% end

poolsize_check = matlabpool('size');
if poolsize_check==0
	matlabpool('local', pool_size);
elseif poolsize_check > 0 && poolsize_check < pool_size
	matlabpool close force;
	matlabpool('local', pool_size);
end