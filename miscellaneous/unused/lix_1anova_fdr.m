% lix_1anova_fdr: one-way anova with fdr correction
% usage: [F, P, P_fdr, P_masked ] = ...
%               lix_1anova_fdr(data, method, permutation, alpha, fdralpha,)

function [F, P, P_fdr, P_masked ] = lix_1anova_fdr(varargin)

try
    d = varargin{1};
    if nargin < 2
        m = 'perm';
        n = 5000;
        alpha = 0.05;
        fdralpha = 0.05;
        fdrtype = 'nonParametric';
    elseif nargin == 6
        m = varargin{2};
        n = varargin{3};
        alpha = varargin{4};
        fdralpha = varargin{5};
        fdrtype = varargin{6};
    elseif nargin <= 3
        m = varargin{2};
        n = varargin{3};
        alpha = 0.05;
        fdralpha = 0.05;
        fdrtype = 'nonParametric';
    elseif nargin <= 5
        m = varargin{2};
        n = varargin{3};
        alpha = varargin{4};
        fdralpha = varargin{5};
        fdrtype = 'nonParametric';
    end
    
    [F df pvals] = statcond(d, 'method', m, 'naccu', n, 'alpha', alpha);
    [p_fdr, p_masked] = fdr(pvals, fdralpha, fdrtype);
    P = pvals;
    P_fdr = p_fdr;
    P_masked = p_masked;
catch err
    lix_disperr(err)
end