function [pval,Factual,df,Fdist] = randanova2(m,groups,num,interaction)

% function [pval,val,dist] = randanova2(m,groups,num,interaction)
%
% Estimate p-value for one-way ANOVA using permutation.
% For further information on using permutation to calculate signficance
% tests see Anderson (doi:10.1139/cjfas-58-3-626).
%
% <m> is vector of data
% <groups> is cell array of grouping variable. Limited to two. 
% <num> (optional) is number of randomizations.  default: 1000.
% <interaction> boolean to test for interaction (1) or not (0). Default 0
%
% Applies Still and White's (1981) approach to calculate interaction effect
% Applies Anderson's (doi:10.1139/cjfas-58-3-626) suggestion to calculate main effects
% In both, a reduced ANOVA model is fit to the data and the residuals are
% used to calculate stats. For interaction, both factor means are
% subtracted from values. For main effects, only non-focal factor means are
% subtracted when each factor is tested separately.
%
% returns 
%   p-values in <pval>, 
%   actual F value in <Factual>
%   d.f. in df (factor 1, factor 2, interaction (if requested), error)
%   distribution of randomly obtained F values in <Fdist>
% 
%
% Returns p values for main effects and interaction (if requested) as
% Factor1
% Factor2
% Factor1*2
%
% This test runs very quickly in parallel mode. Type matlabpool to enable.
% 
% e.g.
%   y = [52.7 57.5 45.9 44.5 53.0 57.0 45.9 44.0]';
%   g1 = [1 2 1 2 1 2 1 2]; 
%   g2 = {'hi';'hi';'lo';'lo';'hi';'hi';'lo';'lo'};
%   [pval, Factual,Fdist]=randanova2(y,{g1 g2},100,1);
%
%   pval =
%
%       0.5700
%       0.0800
%       0.0100
%
%
%   Factual =
%
%       1.0167
%       53.5057
%       248.1525
%
%   df =
%
%       1
%       1
%       1
%       4
%
%
% $	Author: David Stern	$   $   Date :2013/07/30   $
% $ Janelia Farm Research Campus, HHMI, Ashburn, VA
%

if ~exist('num','var') || isempty(num)
  num = 1000;
end

if ~exist('interaction','var') || isempty(num)
    interaction = 0;
end

fun = (@(x) anovan(x,groups,'display','off'));
intfun = (@(x) anovan(x,groups,'display','off','model','interaction'));

% calc actual
if ~interaction
    [~,Table,stats] = feval(fun,m);
    Fcolumn = find(strcmp('F',Table(1,:)));
    Factual = zeros(2,1);
    df = zeros(2,1);
    for i = 1:2
        Frow = find(strcmp(['X' num2str(i)],Table(:,1)));
        Factual(i,1) = cell2mat(Table(Frow,Fcolumn));
        DFcolumn = find(strcmp('d.f.',Table(1,:)));
        df(i) = Table{Frow,DFcolumn};
    end
    Errorrow = find(strcmp('Error',Table(:,1)));
    df(3) = Table{Errorrow,DFcolumn};

else
    [~,Table,stats] = feval(intfun,m);
    Fcolumn = find(strcmp('F',Table(1,:)));
    Factual = zeros(2,1);
    df = zeros(2,1);
    for i = 1:2
        Frow = find(strcmp(['X' num2str(i)],Table(:,1)));
        Factual(i,1) = cell2mat(Table(Frow,Fcolumn));
        DFcolumn = find(strcmp('d.f.',Table(1,:)));
        df(i) = Table{Frow,DFcolumn};
    end
    Frow = find(strcmp('X1*X2',Table(:,1)));
    Factual = cat(1,Factual,Table{Frow,Fcolumn});
    DFcolumn = find(strcmp('d.f.',Table(1,:)));
    df(3) = Table{Frow,DFcolumn};
    Errorrow = find(strcmp('Error',Table(:,1)));
    df(4) = Table{Errorrow,DFcolumn};
end

% Use Anderson's suggestion for main effects
% Get residuals from reduced model, subtract effects of non-focal factor
Fdist = zeros(num,numel(groups));

% Calc first factor first
Frow = find(strcmp('X1',Table(:,1)));
idx = grp2idx(groups{2});

parfor p=1:num
    permm = zeros(numel(stats.resid),1);
    for j = 1:numel(unique(idx)); %permute each unique factor separately
        permm(idx==j) = datasample(stats.resid(idx==j),sum(idx==j),'Replace',false);
    end
    [~,Table,~] = feval(fun,permm);
    Fcolumn = find(strcmp('F',Table(1,:)));
    Fdist(p,1) = cell2mat(Table(Frow,Fcolumn));
    
end

% Calc second factor
Frow = find(strcmp('X2',Table(:,1)));
idx = grp2idx(groups{1});

parfor p=1:num
    permm = zeros(numel(stats.resid),1);
    for j = 1:numel(unique(idx)); %permute each unique factor separately
        permm(idx==j) = datasample(stats.resid(idx==j),sum(idx==j),'Replace',false);
    end
    [~,Table,~] = feval(fun,permm);
    Fcolumn = find(strcmp('F',Table(1,:)));
    Fdist(p,2) = cell2mat(Table(Frow,Fcolumn));
    
end


pval = zeros(numel(groups),1);
for i = 1:numel(groups)
    pval(i) = sum(ge(Fdist(:,i),Factual(i,:))) / num;
end

% Use Still and White's approach to calculate interaction effect
% Get residuals from reduced model. Permute these residuals

if interaction
    %calc significance of interaction
    Fint = zeros(num,1);
    parfor p = 1:num
        %note, stats are from reduced model, line 43
        permm = datasample(stats.resid,numel(stats.resid),'Replace',false)
        [~,Table,~] = feval(intfun,permm);
        Fcolumn = find(strcmp('F',Table(1,:)));
        Fint(p) = cell2mat(Table(Frow,Fcolumn));
    end
    Fdist = cat(2,Fdist,Fint);
    intpval = sum(ge(Fdist(:,3),Factual(3,:))) / num;
    pval = cat(1,pval,intpval);
end

