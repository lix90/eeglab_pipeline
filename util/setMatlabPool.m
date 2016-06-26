function setMatlabPool(poolSize)

if matlabpool('size') == 0
    matlabpool('local', poolSize);
elseif matlabpool('size') ~= poolSize
    matlabpool('close')
    matlabpool('local', poolSize);
end