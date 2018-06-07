function [f,Pxx,Pxxs] = pds_mtm0(t,x,f_res)
% PDS_MTM0 - Multi-taper spectral estimate
%    This is DW's adaptation of Adam Taylor's PDS_MTM code
%    [ff,Pxx,Pxxs] = PDS_MTM0(tt,xx,fres) calculates one-side multi-taper
%    spectrogram.
%
%      TT [Tx1] indicates time points.
%      XX [TxN] is the (optical) data.
%      RES_FFT [1x1] is the half-width of the transform of the tapers used;
%                    It must be in reciprocal units of those of TT.
%
%      FF [Fx1] is the resulting (one-sided) frequency base.
%      Pxx [FxN] are the spectral estimates for the data XX at frequencies FF.
%      Pxxs [FxNxK] optionally returns the data for each taper individually.
%
%    Note that the nature of the beast is that the output Pxx has a 
%    full width of 2*FRES even if the signal XX is perfectly sinusoidal.
%
%    This code is based on work by Adam Taylor, whose contributions are
%    gratefully acknowledged.

[T N]=size(x);
if T==1 && N>1
  x=x(:);
end

% From Adam's comments:
% t is a col vector
% elements of t are evenly spaced and increasing
% x is a real matrix with the same number of rows as t
% f_res is the half-width of the transform of the tapers used
%   it must be in reciprocal units of those of t
% N_fft is the length to which data is zero-padded before FFTing
% this works on the columns of x independently
%
% f is the frequncy base, which is one-sided
% Pxx's cols are the the one-sided spectral estimates of the cols of x
% Pxxs is 3D, (frequency samples)x(cols of x)x(tapers), gives the spectrum
%   estimate for each taper

% we assume that x is real, and return the one-side periodogram

tapers=[];
N_fft=2^ceil(log2(length(t)));

% get the timing info, calc various scalars of interest
N=length(t);  % n of time samples
N_signals=size(x,2);  % n of signals
dt=(t(N)-t(1))/(N-1);
fs=1/dt;

% compute nw and K
nw=N*dt*f_res;
K=floor(2*nw-1);
if K<=0
  error('Signal too short for requested frequency resolution');
end

tapers = dpss(N,nw,K);
tapers=reshape(tapers,[N 1 K]);


% zero-pad, taper, and do the FFT
x_tapered=repmat(x,[1 1 K]).*repmat(tapers,[1 N_signals 1]);
X=fft(x_tapered,N_fft);

% convert to PDSs by squaring and normalizing appropriately
Pxxs=(abs(X).^2)/fs;

% fold the positive and negative frequencies together
[Pxxs,f]=sum_pos_neg_freqs(Pxxs);
f=fs*f;

% average all the spectral estimates together
Pxx=mean(Pxxs,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Pxxs_os,f_os] = sum_pos_neg_freqs(Pxxs_ts)

% turns a two-sided PSD into a one-sided
% works on the the cols of Pxx_ts
% doesn't work for ndims>3

% get the dims of Pxx_ts
[N,N_signals,K]=size(Pxxs_ts);

% fold the positive and negative frequencies together
% hpfi = 'highest positive frequency index'
% also, generate frequency base
hpfi=ceil(N/2);
if mod(N,2)==0  % if N_fft is even
  Pxxs_os=[Pxxs_ts(1:hpfi,:,:) ; zeros(1,N_signals,K) ]+...
          [zeros(1,N_signals,K) ; flipdim(Pxxs_ts(hpfi+1:N,:,:),1) ];
  f_os=(0:hpfi)'/N;
else
  Pxxs_os=Pxxs_ts(1:hpfi,:,:)+...
          [zeros(1,N_signals,K) ; flipdim(Pxxs_ts(hpfi+1:N_fft,:,:),1)];
  f_os=(0:(hpfi-1))'/N;
end
