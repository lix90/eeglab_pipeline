function s = easyparse(caller_varargin,allowed_names)
% easyparse    Parse parameter-value pairs without using inputParser
%   easyparse is called by a function which takes parameter value pairs and
%   creates individual variables in that function. It can also be used to
%   generate a struct like inputParser.
%
%   - To create variables in the function workspace according to the
%     varargin of parameter-value pairs, use this syntax in your function:
%       easyparse(varargin)
%
%   - To create only variables with allowed_names, create a cell array of
%     allowed names and use this syntax:
%       easyparse(varargin, allowed_names);
%
%   - To create a struct with fields specified by the names in varargin,
%     (similar to the output of inputParser) ask for an output argument:
%       s = easyparse(...);
%  
%   CAVEAT UTILITOR: this function relies on assignin statements. Input
%   checking is performed to limit potential damage, but use at your own 
%   risk.
%
%   Author: Jared Schwede
%   Last update: January 14, 2013

    % We assume all inputs come in parameter-value pairs. We'll also assume
    % that there aren't enough of them to justify using a containers.Map. 
    for i=1:2:length(caller_varargin)
        if nargin == 2 && ~any(strcmp(caller_varargin{i},allowed_names))
            error(['Unknown input argument: ' caller_varargin{i}]);
        end
        
        if ~isvarname(caller_varargin{i})
            error('Invalid variable name!');
        end
        
        
        % We assign the arguments to the struct, s, which allows us to
        % check that the assignin statement will not either throw an error 
        % or execute some nasty code.
        s.(caller_varargin{i}) = caller_varargin{i+1};
        % ... but if we ask for the struct, don't write all of the
        % variables to the function as well.
        if ~nargout
            if exist(caller_varargin{i},'builtin') || (exist(caller_varargin{i},'file') == 2) || exist(caller_varargin{i},'class')
                warning('MATLAB:defined_function',['''' caller_varargin{i} ''' conflicts with the name of a function, m-file, or class along the MATLAB path and will be ignored by easyparse.' ...
                                            ' Please rename the variable, or use a temporary variable with easyparse and explicitly define ''' caller_varargin{i} ...
                                            ''' within your function.']);
            else
                assignin('caller',caller_varargin{i},caller_varargin{i+1});
            end
        end
    end
end