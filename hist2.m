function [nn,xx,yy] = hist2(x,y, nx,ny,makenan)
% HIST2   Two dimensional histogram
%    HIST2(x,y, nx,ny) plots a 2D histogram of the data (X,Y), with NX
%    bins in the x-direction, and NY bins in the y-direction.
%    nn = HIST2(...) returns the bin counts instead of plotting; NN will
%    be shaped NYxNX.
%    [nn,xx,yy] = HIST2(...) returns the positions of the bin centers also,
%    with XX a row vector and YY a column vector, suitable for plotting
%    using IMAGESC(xx,yy,nn).
%    Instead of NX and NY being scalars, they can be triplets [X0 DX X1]
%    and [Y0 DY Y0] to represent explicitly the centers of bins.
%    Normally, x-values that lie outside the range (X0-DX/2,X1+DX/2) are
%    mapped to the leftmost and rightmost bins as appropriate, and similarly
%    for y-values outside the range (Y0-DY/2,Y1+DY/2). Instead, such values
%    can be discarded by calling HIST2(x,y, nx,ny, 1).
%    CAUTION: With NX or NY simple integers, this function does NOT ensure
%    that every data point falls within a bin. Rather, the bin centers
%    are placed based on percentiles of the data.

if nargin<3
  nx=10;
end
if nargin<4
  ny=10;
end
if nargin<5
  makenan=0;
end

if length(nx)==3
  x0=nx(1);
  dx=nx(2);
  x1=nx(3);
  nx=round(1+(x1-x0)/dx);
elseif length(nx)==1
  x_ = sort(x); N=length(x);
  x0 = x_(ceil(N/nx));
  x1 = x_(ceil(N-N/nx));
  dx = (x1-x0)/(nx-1);
else
  error('NX must be a scalar or a [X0 DX X1] triplet');
end


if length(ny)==3
  y0=ny(1);
  dy=ny(2);
  y1=ny(3);
  ny=round(1+(y1-y0)/dy);
elseif length(ny)==1
  y_ = sort(y); N=length(y);
  y0 = y_(ceil(N/ny));
  y1 = y_(ceil(N-N/ny));
  dy = (y1-y0)/(ny-1);
else
  error('NY must be a scalar or a [Y0 DY Y1] triplet');
end

x = floor((x - (x0-dx/2)) / dx);
if makenan
  x(x<0)=nan;
  x(x>=nx)=nan;
else
  x(x<0)=0;
  x(x>=nx)=nx-1;
end

y = floor((y - (y0-dy/2)) / dy);
if makenan
  y(y<0)=nan;
  y(y>=ny)=nan;
else
  y(y<0)=0;
  y(y>=ny)=ny-1;
end

ok=~isnan(x+y);

nn = hist(y(ok) + ny*x(ok),[0:nx*ny-1]);
nn = reshape(nn,[ny nx]);

if nargout==1
  return
end

xx=[x0:dx:x1];
yy=[y0:dy:y1]';

if nargout==3
  return
end

if nargout==0
  imagesc(xx,yy,nn);
  clear xx yy nn
  return
end

error('Wrong number of output arguments');
