function outvector = to_col_vector(inputdata)
% transform matrix (2 dimensions) into column vector

if ndims(inputdata)>2
    disp('Error: inputdata must have 2 dimensions.')
    return;
end

if all(size(inputdata)==1)
    disp('***** Warning: inputdata has only one element. *****');
    outvector = inputdata;
elseif any(size(inputdata)==1)
    if size(inputdata,1)==1
        outvector = inputdata';
    else
        outvector = inputdata;
    end
else
    outvector = inputdata(:);
end



