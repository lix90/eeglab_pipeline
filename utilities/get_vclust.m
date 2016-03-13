% find cluster in vector
function clustInd = get_clustInd()

indices = [];
thresh = 3;
alpha = 0.05;

vector = pvals;
vectorNew = find(vector<alpha);
n = 1
clustNum = 0;
clustCell = cell();
clustInd = cell();
vectorNewNum = numel(vectorNew)


%% reject singles
rej = zeros(vectorNewNum, 1);
for i = 1:2:vectorNewNum
	if i == 1
		if vectorNew(i)+1 ~= vectorNew(i)
			rej(i) = 1;
		end
	elseif 1 < i < vectorNewNum
		if vectorNew(i-1) ~= vectorNew(i)-1 && vectorNew(i+1) ~= vectorNew(i)+1
			rej(i) = 1;
		end
	elseif i == vectorNewNum
		if vectorNew(i-1) ~= vectorNew(i)-1
			rej = [rej, 1];
		end
	end
end
vectorRej = vectorNew(~rej);

% find cluster
vectorRejNum = numel(vectorRej)
j = 1;
while 


end