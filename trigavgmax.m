function [mx,dt] = trigavgmax(trc,dtt,tslack)
% TRIGAVGMAX - Find peak in triggered average
%    [mx,dt] = TRIGAVGMAX(avg,dtt) returns the amplitude and time of the
%    largest peak in the triggered average AVG with latency timestamps DTT.
%    (Normally, AVG and DTT are as returned by TRIGAVG.)
%    [mxx,dt] = TRIGAVGMAX(trc,dtt) operates on the individual traces. In
%    this case, the time of the average peak is first determined, then each
%    trace is examined for a peak within 0.2 ms of this average.
%    [mxx,dt] = TRIGAVGMAX(trc,dtt,tslack) overrides this default.
%    All times are nominally in milliseconds.
%    This funcion uses Fourier upsampling to 100 kHz to improve precision
%    of time values.

if nargin<3
  tslack = 0.2;
end

S=size(trc);
L=length(trc);
if prod(S)==L
  % We're working on an average already
  avg = trc(:);
else
  % We're working with individual traces
  avg = mean(trc,2);
  L = length(avg);
end

% First, let's get a coarse estimate of the peak
[mx0,i0] = max(avg);
t0=dtt(i0);

% Now, let's reinterpolate to do a little better
fac = ceil(mean(diff(dtt)) / 0.01); % Upsample to 100 kHz
%dt_detail = [t0-tslack:0.01:t0+tslack];
%avg_detail = interp1(dtt,avg,dt_detail,'pchip','extrap');
[avg_detail, dt_detail] = upsample(avg,fac,dtt);
[mx,i1] = max(avg_detail);
dt = dt_detail(i1);

% OK. We now have the information about the average peak. 
if prod(S) ~= L
  % Let's look at the individual traces
  N = S(2);
  mx=zeros(N,1);
  dt=zeros(N,1);
  idx = find(dt_detail>=t0-tslack & dt_detail<=t0+tslack);
  for n=1:N
    yy = trc(:,n);
    bd=isnan(yy);
    yy(bd) = mean(yy(~bd));
    trc_detail = upsample(yy,fac,dtt);
    yy = trc_detail(idx);
    xx = dt_detail(idx);
    %trc_detail = interp1(dtt,trc(:,n),dt_detail,'pchip','extrap');
    [mx(n),i1] = max(yy);
    dt(n) = xx(i1);
  end
end
