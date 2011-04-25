function f=medianflt(f)
% y = MEDIANFLT(x) passes the vector x through a 3 point median filter.
% If X is a matrix, works in first dimension.

[X Y] = size(f);
if X==1
  f=f';
  L=Y;
else
  L=X;
end
f=median(cat(3,[f(1,:); f; f(L,:)],[f; f(L,:); f(L,:)],[f(1,:); f(1,:); f]),3);
f=f(2:L+1,:);
if X==1
  f=f';
end
