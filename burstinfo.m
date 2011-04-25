function brst = burstinfo(t_spk, dt_thr, t_end)
% BURSTINFO - Determine statistics about bursts in a spike train
%    brst = BURSTINFO(t_spk, dt_thr) detects bursts in the spike train
%    with spike time T_SPK, based on a simple threshold criterion:
%    Any group of three or more spikes with spike intervals less than
%    DT_THR is a burst.
%
%    This returns a structured variable with the following fields:
%
%       T_START:  time of first spike in a burst
%       T_END:    time of last spike in a burst
%       T_MIDDLE: time of middle spike in a burst
%       DUR:      duration of a burst
%       N:        number of spikes in burst
%       IBI_PRE:  interval between previous burst's end and this burst's start
%       IBI_POST: interval between this burst's end and next start
%       ISI_PRE:  interval between last spike before this burst and start of
%                 this burst
%       ISI_POST: interval between end of this burst and next spike
%       PER_PRE:  period between middle spike of previous burst and this
%       PER_POST: period between middle spike of this burst and next's
%       I_START:  index of first spike in burst
%       I_END:    index of last spike in burst
%
%    Each field is an Nx1 vector, where N is the number of bursts.
%
%    Notes:
%
%     - The _PRE fields are undefined for the first burst (set to NaN),
%       and the _POST fields are undefined for the last burst.
%     - If the recording was started or ended in the middle of a burst,
%       the information about the first or last burst will be about whatever
%       part of the burst inside the recording. If you only want information
%       about bursts that definitely were recorded entirely, call this
%       function as:
%
%          brst = BURSTINFO(t_spk, dt_thr, t_end).
%       
%       That tells the burst detector that the recording started at t=0 and
%       ended at T_END, so that if the first spike occurred before t=0+dt_thr
%       or the last spike occurred after t_end-dt_thr, there could be a 
%       partial burst, which will then not be reported.

if nargin<3
  t_end=inf;
end

K=length(t_spk);
dt = diff([inf; t_spk(:); inf]);

[ion,iof] = schmitt(1./dt,1/dt_thr, .95/dt_thr);
nspk = 1+iof-ion;

if t_end<inf
  ok = nspk>=3 & (ion>1 | t_spk(ion-1)>dt_thr) & ...
      (iof<=K | t_spk(iof-1)<t_end-dt_thr);
else
  ok = nspk>=3;
end

brst.i_start = ion(ok)-1;
brst.i_end   = iof(ok)-1;
brst.t_start = t_spk(brst.i_start);
brst.t_end   = t_spk(brst.i_end);

N = length(brst.i_start);
brst.t_middle = zeros(N,1);
for n=1:N
  brst.t_middle(n) = median(t_spk(brst.i_start(n):brst.i_end(n)));
end
brst.dur = brst.t_end - brst.t_start;
brst.n   = nspk(ok);

ibi = brst.t_start(2:end) - brst.t_end(1:end-1);
brst.ibi_pre = zeros(N,1) + nan;
brst.ibi_pre(2:end) = ibi;
brst.ibi_post = zeros(N,1) + nan;
brst.ibi_post(1:end-1) = ibi;

brst.isi_pre = zeros(N,1) + nan;
brst.isi_post = zeros(N,1) + nan;

haspre = find(brst.i_start>1);
brst.isi_pre(haspre) = brst.t_start(haspre) - t_spk(brst.i_start(haspre)-1);
haspost = find(brst.i_end<K);
brst.isi_post(haspost) = t_spk(brst.i_end(haspost)+1) - brst.t_end(haspost);

per = diff(brst.t_middle);
brst.per_pre = zeros(N,1) + nan;
brst.per_post = zeros(N,1) + nan;
brst.per_pre(2:end) = per;
brst.per_post(1:end-1) = per;

