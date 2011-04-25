function [y,idx] = upsample(x,n,t)
% UPSAMPLE - Fourier upsampling 
%   y = UPSAMPLE(x,n) uses Fourier upsampling to improve temporal
%   resolution on signal X by a factor N.
%   UPSAMPLE operates on the first non-singleton dimension of X.
%   [y,t] = UPSAMPLE(x,n) returns the indices of the output.
%   [y,t] = UPSAMPLE(x,n,t) returns the time stamps of the output.
%   Caution: if the length of X is odd, the last data point is dropped.

if nargin<3
  t=[];
end

[x,perm] = autopermute(x);

[A,B] = size(x);

if n==1
  y=x;
  idx=[1:A]';
else
  L=floor(A/2);
  f = fft(x(1:2*L,:));
  f = [f(1:L,:); zeros(L*2*(n-1),B); f(L+1:2*L,:)];
  y = real(ifft(f)) * n;
  idx=[0:n*2*L-1]'/n + 1;
end
y = autoipermute(y,perm);

if nargout>=2
  if ~isempty(t)
    idx=interp1([1:A],t,idx,'linear');
  end
  idx = autoipermute(idx,perm);
else
  clear idx
end
