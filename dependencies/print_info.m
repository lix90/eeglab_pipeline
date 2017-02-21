function print_info(whole, ind)

if ~iscell(whole)
    disp('Error: The 1st argument must be a cell.');
    return;
end

if round(ind)~=ind
    disp('Error: The 2nd argument must be an integer.');
    return;
end

if nargin<2
    disp('Error: not enough input arguments.');
    return;
end

fprintf('\n\n***** No.%i/%i: %s *****\n\n', ...
        ind, length(whole), whole{ind});
