function Vint = int2clean(Vint, tt, Iint, plotflg)
% INT2CLEAN - Clean up intracellular recording for SUC2SPIKE
%    vcln = INT2SPIKE(vraw,tt) takes a voltage trace from an intracellular
%    electrode and attempts to clean it using the techniques in Chapter 4 
%    of the Tutorial.
%    vcln = INT2SPIKE(vraw,tt,iraw) also removes voltage steps caused by
%    poor bridge balance, by dropping voltage steps that co-occur with steps
%    in the current trace IRAW. Only current steps greater than 0.1 are used.
%    vcln = INT2SPIKE(...,1) creates some plots to indicate progress.

dt_s = mean(diff(tt));
f0_hz = 1/dt_s;

DI = ceil(1e-3/dt_s); % Skip 1 ms around steps
fcut_hz = 50;

if nargin<3
  Iint=[];
end
if nargin<4
  if length(Iint)==1
    plotflg = Iint;
    Iint = [];
  else
    plotflg = 0;
  end
end

if plotflg
  f=figure(89);
  clf
  %  subplot(2,1,1);
  plot(tt,Vint,'g');
  xlabel 'Time (s)'
  ylabel 'Voltage (mV)'
end

if ~isempty(Iint)
  L = length(Vint);
  badidx = find([nan; abs(diff(Iint(:)))]>0.1);
  for k=1:length(badidx)
    i0 = max(badidx(k)-DI,1);
    i1 = min(badidx(k)+DI,L);
    v0 = Vint(i0);
    v1 = Vint(i1);
    Vint(i1:end)=Vint(i1:end) + v0-v1;
    yy(i0+1:i1-1) = v0;
  end
end

if plotflg
  hold on
  plot(tt,Vint,'c');
end

[b,a] = butterhigh1(fcut_hz / f0_hz);
Vint = filtfilt(b,a, Vint);

if plotflg
  hold on
  plot(tt,Vint,'m');
end

Vint = templatefilter(Vint, f0_hz/60, 200/f0_hz, 50);

if plotflg
  hold on
  plot(tt,Vint,'y');
end

Vint = medianflt(Vint);

if plotflg
  hold on
  plot(tt,Vint,'k');
end
