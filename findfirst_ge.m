function idx = findfirst_ge(xx,y)
% FINDFIRST_GE - Return the first index of a big enough number
%    idx = FINDFIRST_GE(xx,y) returns the index of the first element
%    in XX that is greater or equal to Y.

idx = find(xx>=y, 1);
if isempty(idx)
  idx = 0;
end
