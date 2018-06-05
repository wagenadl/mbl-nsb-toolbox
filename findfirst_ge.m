function idx = findfirst_ge(xx,y)
% FINDFIRST_GE - Return the first index of a big enough number
%    idx = FINDFIRST_GE(xx,y) returns the index of the first element
%    in XX that is greater or equal to Y.
%    This is a primitive implementation.

idx = find(xx>=y);
if isempty(idx)
    idx = 0;
else
    idx = idx(1);
end
