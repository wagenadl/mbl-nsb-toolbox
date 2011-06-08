% First, from the shell, run:
%    axgr2m mn3_080414_002

% Then, in matlab:

load intracel.mat

figure(1); clf
subplot(2,1,1);
plot(tt,ii);
xlabel 'Time (s)'
ylabel 'Current (nA)'

subplot(2,1,2);
plot(tt,vv);
xlabel 'Time (s)'
ylabel 'Voltage (mV)'


L=length(vv);
DI=4;

yy=vv;

badidx=find([nan abs(diff(ii))]>.1);
for k=1:length(badidx)
  i0=max(badidx(k)-DI,1);
  i1=min(badidx(k)+DI,L);
  v0 = yy(i0);
  v1 = yy(i1);
  yy(i1:end) = yy(i1:end) + v0-v1;
  yy(i0+1:i1-1)=v0;
end

figure(2); clf
plot(tt,yy);
xlabel 'Time (s)'
ylabel 'Voltage (mV)'
title 'After removing step transients'


dt_s = mean(diff(tt));
f0_hz = 1/dt_s;
fcut_hz = 50;
[b,a]=butterhigh1(fcut_hz/f0_hz);
zz=filtfilt(b,a,yy);

figure(3); clf
plot(tt,zz);
xlabel 'Time (s)'
ylabel 'Voltage (mV)'
title 'After filtering above 50 Hz'

ww = templatefilter(zz,f0_hz/60,200/f0_hz,50);
figure(4); clf
plot(tt,ww);
xlabel 'Time (s)'
ylabel 'Voltage (mV)'
title 'After removing 60 Hz interference'

spk=detectspike(ww,tt,2,2);
gdspk=selectspike(spk);

figure(5); clf
plot(tt,ww);
hold on
plot(spk.tms,spk.amp,'k.');
plot(gdspk.tms,gdspk.amp,'r.');
xlabel 'Time (s)'
ylabel 'Voltage (mV)'

