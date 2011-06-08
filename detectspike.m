function spk = detectspike(dat,tms,fac,t0,tkill)
% DETECTSPIKE - Extract spike times from suction electrode traces
%    spk = DETECTSPIKE(dat,tms) detects spikes in a raw electrode trace 
%    and returns spike times and amplitudes in a structure:
%
%       SPK.TMS: spike times
%       SPK.AMP: spike amplitudes
%
%    This function will return many "spikes" that are actually just noise.
%    Use SELECTSPIKE to sort this out.
%
%    spk = DETECTSPIKE(dat,tms,thr,tbin,tkill) overrides the default
%    threshold factor THR = 4 over RMS noise, the default bin size
%    of TBIN = 20 ms, and the default minimum interval between detectable
%    spikes of TKILL = 10 ms.

if nargin<3 
  fac=[];
end
if isempty(fac)
  fac=4;
end
if nargin<4
  t0=[];
end
if isempty(t0)
  t0=20;
end
if nargin<5
  tkill=[];
end
if isempty(tkill)
  tkill = 10;
end

dat=dat(:);
if prod(size(tms))==1
  fs = tms;
  tstart = 1/fs;
else
  tms=tms(:);
  fs = 1/mean(diff(tms)); % Get sampling frequency
  tstart = tms(1);
end

[b1,a1]=butterhigh1(50/fs);
datf = filtfilt(b1,a1,dat);

if fs>4e3
  [b2,a2]=butterlow1(2e3/fs);
  datf = filtfilt(b2,a2,datf);
end

K=ceil(t0*.001*fs); % Number of samples in 20 ms.
spki = dwgetspike(datf,[fac K 40 tkill*fs/1e3]);

spk.tms = tstart + (spki-1)/fs;
spk.amp = dat(spki);

