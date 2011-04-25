function [yy,tpl]=templatefilter(xx,period_sams,f_max,npers)
% TEMPLATEFILTER - Remove 60 Hz line noise by template filtering
%    yy = TEMPLATEFILTER(xx,period_sams,f_max,npers) removes (nearly) periodic 
%    noise (such as 60 Hz line pickup) from the signal XX. 
%    PERIOD_SAMS is the period of the noise, which need not be integer.
%    E.g., for 60 Hz noise removal from a signal sampled at 10 kHz, you'd
%    set PERIOD_SAMS = 10000/60.
%    F_MAX is the maximum frequency expect to exist in the periodic noise;
%    noise (or signal) above that frequency is not treated. Measured
%    in units of the sample frequency. Typical: F_MAX = 500/10000.
%    NPERS is the number of periods to use for estimation.
%    TEMPLATEFILTER works on vectors, or on the columns of NxD arrays.
if nargin<4
  npers = 50;
end
if nargin<3
  f_max=[];
end

if prod(size(xx)) ~= length(xx)
  % Not a vector
  S=size(xx);
  xx = reshape(xx,[S(1) prod(S(2:end))]);
  [X,Y] = size(xx);
  yy = zeros(X,Y);
  for y=1:Y
    yy(:,y) = templatefilter(xx(:,y),period_sams,f_max,npers);
  end
  yy = reshape(yy,S);
end


% Step one: resample the original signal to make period_sams be integer.
X=length(xx);
int_sams = floor(period_sams);
rat = period_sams / int_sams;
zz = interp1([1:X],xx,[1:rat:X],'linear');

% Step two: reshape into a matrix with one period per column (dropping
% the final partial period).
Z = length(zz);
N = floor(Z/int_sams);
zz = reshape(zz(1:N*int_sams),[int_sams N]);

% Step three: filter consecutive periods
[b,a]=butterlow1(1/npers);
zz = filtfilt(b,a,zz')';

% Step four: Smooth the template by assuming there are no
% high frequency components to the pickup.
if ~isempty(f_max)
  [b,a]=butterlow1(f_max); % Where f_max is in units of sample frequency.
  zz = filtfilt(b,a,zz);
end

% Step five: add an extra period at the end, based on the final period,
% to compensate for data cut in step two.
zz(:,N+1)=zz(:,N);

% Step six: Remove DC from the template.
zz = zz - repmat(mean(zz),[int_sams 1]);

% Step seven: reshape back to a vector, and resample back to original frequency.
zz = zz(:);
Z=length(zz);
zz = interp1([1:Z],zz,[1:1/rat:Z],'linear');

% Step eight: subtract the template from the original signal.
yy = xx - reshape(zz(1:X),size(xx));

if nargout>=2
  tpl=reshape(zz(1:X),size(xx));
end
