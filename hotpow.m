function cc=hotpow(n,p)
% cc=HOTPOW(n,p) returns a resampled flipud(HOT) colormap of n elements
% indexing by i^p. This is a useful colormap for printing.

if nargin<2
  p=.5;
end

if nargin<1
  n=64;
end

cc=flipud(hot(10001));
cc=interp1([0:10000]/10000,cc,([0:n-1]/(n-1)).^p,'linear');
