function yy = gsmooth(xx,rx,sigmul)
% yy = GSMOOTH(xx,rx) returns a smoothed version of XX using a Gaussian
% window of radius RX. RX is the sigma of the Gaussian.
% Sometimes one prefers to use the FWHM instead. To do that, call
% yy = GSMOOTH(xx,-fwhm).
% NB: Analytically, FWHM = 2*sqrt(log(4)) * RX ~= 2.355 * RX.
%
% GSMOOTH operates on vectors, or on the first dimension of general matrices.
%
% The main advantage of GSMOOTH over FILTFILT or GAUSSIANBLUR1D is the way it
% treats edges: it keeps RX constant near edges (as do FILTFILT and 
% GAUSSIANBLUR1D), but unlike FILTFILT and GAUSSIANBLUR1D it correctly 
% normalizes considering the fact that part of the Gaussian is outside the
% domain of the data.
%
% GSMOOTH works by convolving with a Gaussian defined up to +/- 4*sigma. For
% most purposes that's enough precision. The multiplier (4) can be specified
% as a third argument to GSMOOTH.

if nargin<3
  sigmul=4;
end

if rx<0
  rx = -rx / (2*sqrt(log(4)));
end

S = size(xx);

if S(1)==1 & length(S)==2
  xx=xx';
end

S_ = size(xx);
if length(S_)>2
  xx=reshape(xx,[S_(1) prod(S_(2:end))]);
end

[L,D]=size(xx);

R = ceil(sigmul*rx);

gg=exp(-.5*([-R:R]'/rx).^2); G=(length(gg)-1)/2;

one_ = conv(ones(L,1),gg); one_ = one_(G+1:end-G);

yy=zeros(L,D);

for d=1:D
  cc = conv(xx(:,d),gg);
  yy(:,d) = cc(G+1:end-G) ./ one_;
end

if length(S_)>2
  yy=reshape(yy,S_);
end

if S(1)==1 & length(S)==2
  yy=yy';
end
