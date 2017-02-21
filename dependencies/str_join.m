function output = str_join(input, separator)
%STRJOIN Concatenate an array into a single string.
%
%     S = str_join(C)
%     S = str_join(C, separator)
%
% Description
%
% S = str_join(C) takes an array C and returns a string S which concatenates
% array elements with comma. C can be a cell array of strings, a character
% array, a numeric array, or a logical array. If C is a matrix, it is first
% flattened to get an array and concateneted. S = str_join(C, separator) also
% specifies separator for string concatenation. The default separator is comma.
%
% Examples
%
%     >> str = str_join({'this','is','a','cell','array'})
%     str =
%     this,is,a,cell,array
%
%     >> str = str_join([1,2,2],'_')
%     str =
%     1_2_2
%
%     >> str = str_join({1,2,2,'string'},'\t')
%     str =
%     1 2 2 string
%
% by lix: rename to str_join for conflict with matlab2015's native
% function. @ Saturday, February 18 2017


    if nargin < 2, separator = ','; end
    assert(ischar(separator), 'Invalid separator input: %s', class(separator));
    separator = strrep(separator, '%', '%%');

    output = '';
    if ~isempty(input)
    if ischar(input)
      input = cellstr(input);
    end
    if isnumeric(input) || islogical(input)
      output = [repmat(sprintf(['%.15g', separator], input(1:end-1)), ...
                       1, ~isscalar(input)), ...
                sprintf('%.15g', input(end))];
    elseif iscellstr(input)
      output = [repmat(sprintf(['%s', separator], input{1:end-1}), ...
                       1, ~isscalar(input)), ...
                sprintf('%s', input{end})];
    elseif iscell(input)
        output = str_join(cellfun(@(x)str_join(x, separator), input, ...
                                  'UniformOutput', false), ...
                       separator);
    else
        error('str_join:invalidInput', 'Unsupported input: %s', class(input));
    end
  end
end
