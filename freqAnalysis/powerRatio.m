% delta/alpha
% (delta+theta)/(alpha+theta)
% (delta+theta)/(alpha+beta)
% out.RelativePower{i}(iChan)

D = out.RelativePower{1};
T = out.RelativePower{2};
A = out.RelativePower{3};
B = out.RelativePower{4};

DA = D./A;
DTAT = (D+T)./(A+T);
DTAB = (D+T)./(A+B);

