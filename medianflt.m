function f=medianflt(f, dim)
% y = MEDIANFLT(x) passes the vector x through a 3 point median filter.
% If X is a matrix, works in first dimension.
% y = MEDIANFLT(x, dim) works in the dim-th dimension

if nargin<2
  dim = [];
end

S = size(f);
if isempty(dim)
  if length(S)==2 && S(1)==1
    dim = 2;
  else
    dim = 1;
  end
end

f = reshape(f, [prod(S(1:dim-1)) S(dim) prod(S(dim+1:end))]);
f = median(cat(4, [f(:,1,:), f, f(:,end,:)], ...
                  [f, f(:,end,:), f(:,end,:)], ...
                  [f(:,1,:), f(:,1,:), f]), 4);
f = f(:,2:end-1,:);	      
f = reshape(f, S);	      
