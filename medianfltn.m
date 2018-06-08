function y=medianfltn(x,N)
% y = MEDIANFLTN(x,n) passes the vector through a 2N+1 point median filter.
% If X is a matrix, works in first dimension.

[X_ Y_] = size(x);
if X_==1
  x=x';
end

[X,Y]=size(x);
z=repmat(x, [1 1 2*N+1]);
for n=-N:N
  z(N+n+1:end-N+n,:,n+N+1) = x(N+1:end-N,:);
end

y = median(z,3);

if X_==1
  y=y';
end
