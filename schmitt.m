function [on,off] = schmitt(xx,thr_on,thr_off,laststyle)
% SCHMITT  Schmitt trigger of a continuous process.
%   [on,off] = SCHMITT(xx,thr_on,thr_off) is like a Schmitt trigger:
%   ON are the indices when XX crosses up through THR_ON coming from 
%   below THR_OFF;
%   OFF are the indices when XX crosses down through THR_OFF coming from 
%   above THR_ON.
%   If XX is high at the beginning, the first ON value will be 1.
%   By default, if XX is high at the end, the last upward crossing is ignored.
%   [on,off] = SCHMITT(xx,thr_on,thr_off,1) detects the last upward crossing,
%   making ON be 1 longer than OFF.
%   [on,off] = SCHMITT(xx,thr_on,thr_off,2) detects the last upward crossing,
%   making the last entry of OFF be length(XX)+1.
%   [on,off] = SCHMITT(xx,thr_on,thr_off,3) detects the last upward crossing,
%   making the last entry of OFF be +inf.
%   If THR_OFF is not specified, it defaults to THR_ON/2.
%   If neither THR_ON nor THR_OFF are specified, THR_ON=2/3 and THR_OFF=1/3.

if nargin<3 
    thr_off=[];
end
if nargin<2
  thr_on=[];
end
if isempty(thr_on)
  thr_on = 2/3;
end
if isempty(thr_off)
  thr_off=thr_on/2;
end

if thr_on<=thr_off
  on=[];
  off=[];
  return;
end

if nargin<4
  laststyle=0;
end

xx=xx(:);
up = xx>=thr_on & [-inf; xx(1:end-1)]<thr_on;
dn = xx<thr_off & [inf;  xx(1:end-1)]>=thr_off;
any = up|dn;
idx_any = find(any);

if isempty(idx_any)
  on=[];
  off=[];
  return;
end


typ_any = up(any);
use = [1; diff(typ_any)];

idx_use =idx_any(use~=0);
typ_use = typ_any(use~=0);

if ~isempty(typ_use)
  if typ_use(1)==0
    idx_use = idx_use(2:end);
    typ_use = typ_use(2:end);
  end
end

if laststyle==0 & ~isempty(typ_use)
  if typ_use(end)==1
    idx_use = idx_use(1:end-1);
    typ_use = typ_use(1:end-1);
  end
end

on = idx_use(typ_use==1);
off = idx_use(typ_use==0);

if laststyle>=2 & length(off)<length(on)
  if laststyle==3
    off=[off;inf];
  else
    off=[off;length(xx)+1];
  end
end

%%%% on=[];
%%%% off=[];
%%%% 
%%%% i0 = findfirst_le(xx,thr_off);
%%%% if i0==0
%%%%   return
%%%% end
%%%% 
%%%% while i0<length(xx)
%%%%   di = findfirst_ge(xx(i0+1:end),thr_on);
%%%%   if di==0
%%%%     break
%%%%   end
%%%%   i1 = i0+di;
%%%%   if i1>=length(xx)
%%%%     break
%%%%   end
%%%%   di = findfirst_le(xx(i1+1:end),thr_off);
%%%%   if di==0
%%%%     break
%%%%   end
%%%%   i0 = i1+di;
%%%%   on = [on i1];
%%%%   off = [off i0];
%%%% end

