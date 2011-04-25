function [av,dt_ms,trc] = trigavg(dat,tt_s,ti_s,wid_ms)
% TRIGAVG - Triggered average
%   av = TRIGAVG(dat, tt_s, ti_s) calculates the triggered average of the 
%   signal DAT (which is sampled at times TT, measured in seconds) with 
%   triggers at TI (also measured in seconds).
%   av = TRIGAVG(dat, tt_s, ti_s, wid_ms) also specifies the half-width of
%   the window to be averaged, in milliseconds. WID_MS defaults to 50 ms.
%   [av, dt_ms] = TRIGAVG(...) also returns the relative times of the result.
%   [av, dt_ms, trc] = TRIGAVG(...) also returns the individual windows.
%   This requires that TT_S is uniform.

if nargin<4
  wid_ms = 50;
end

t0 = tt_s(1);
dt = mean(diff(tt_s));
L = length(tt_s);

idx = round(1 + (ti_s-t0) / dt);

idx = idx(idx>=1 & idx<=L);
N = length(idx);

T = ceil(wid_ms / (dt*1e3));
di = [-T:T];

trc = zeros(2*T+1,N) + nan;

for n=1:N
  ii = idx(n) + di;
  ok = find(ii>0 & ii<=L);
  trc(ok,n) = dat(ii(ok));
end

nn = isnan(trc);
trc(nn)=0;
av = sum(trc,2) ./ sum(~nn,2);
trc(nn)=nan;
if nargout>=2
  dt_ms = di*dt*1e3;
end
if nargout<3
  clear trc
end

