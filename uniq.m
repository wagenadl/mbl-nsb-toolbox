function [y,id]=uniq(x)
% UNIQ  Select elements of a vector that are different from their predecessor.
%   y = UNIQ(x) returns those elements of the vector X that are not identical
%   to the previous element.
%   [y,id] = UNIQ(x) also returns an index of uniq elements.
%   No sorting is performed.
%   Output is always Nx1. If X is multidimensional, it is collapsed (by x(:)). 
%   NB: This is similar to the Unix command uniq(1).

if isempty(x)
  y=x;
else
  if iscell(x)
    y={x{1}};
    id=1;
    for n=2:length(x)
      if strcmp(x{n},x{n-1})==0
	y{end+1}=x{n};
	id=[id;n];
      end
    end
  else
    z=[1; diff(x(:))];
    id=find(z~=0);
    y=x(id);
  end
end
if nargout<2
  clear id
end
