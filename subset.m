function x = subset(x, idx)
% SUBSET - Subset of a dataframe
%   y = SUBSET(x, idx), where X is a structure with one or more vector
%   fields, returns that same structure with elements indexed by IDX 
%   preserved from each vector.
%   If X additionally contains nonvectors, or vectors not equal in length
%   to the max length across vectors, those are preserved without
%   subsetting.
%   One exception: tensors with size along the nonsingleton dimension of 
%   IDX matching the other vectors are also treated. For instance, if 
%   fields are TMS(Nx1), AMP(Nx1), CTXT(NxQ), MSG(QxN) then CTXT would
%   be targeted but not MSG.

len = [];
fld = fieldnames(x);
F = length(fld);
for f=1:F
  S = size(x.(fld{f}));
  if prod(S) == max(S) && ~ischar(x.(fld{f}))
    % Non-empty vector
    len(end+1) = max(S);
  end
end
if isempty(len)
  len = 0;
else
  len = max(len);
end

SI = size(idx);
dim = find(SI>1);

for f=1:F
  S = size(x.(fld{f}));
  if prod(S) == max(S) && max(S)==len
    % Vector of appropriate length!
    x.(fld{f}) = x.(fld{f})(idx);
  elseif length(dim)==1 && S(dim)==len
    % Matching tensor
    S1 = S(1:dim-1);
    S2 = S(dim+1:end);
    if isempty(S1)
      S1a = [1];
    else
      S1a = S1;
    end
    ff = reshape(x.(fld{f}), [S1a len S2]);
    ff = ff(:,idx,:);
    N = size(ff, 2);
    x.(fld{f}) = reshape(ff, [S1 N S2]);
  end
end
 
 