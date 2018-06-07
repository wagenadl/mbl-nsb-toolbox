function [f,mag,phase,cohs] = coh_mtm1(t,x,y,f_res,f_star,N_fft,tapers)
% COH_MTM0 - Multi-taper coherence estimate
%    This is DW's adaptation of Adam Taylor's COH_MTM code
%    [ff, mag, phase, cohs] = COH_MTM0(tt, xx, yy, f_res)
%    calculates the coherence of the signals XX (TxN) wrt the 
%    signals YY (Tx1 or TxN), defined at times TT (Tx1) (evenly spaced
%    and increasing).
%    The coherence is calculated with frequency resolution F_RES (which 
%    must be in reciprocal units of those of TT). Results are:
%
%      FF (Fx1): frequency base (one-sided).
%      MAG (FxN): magnitude of coherence (normalized)
%      PHASE (FxN): phase of coherence (-pi..pi). Phase is positive
%                   if YY lags XX. (e.g. if XX = sin(TT), and
%                   YY = sin(TT-0.1), phase at the peak will be +0.1.)
%      COHS (FxNxK): individual complex coherence estimates for each of
%                    the K tapers
%
%    COH_MTM0(..., f_star, PadFFT, tapers) specifies additional
%    parameters:
%
%      F_STAR: calculate only at the frequency F_STAR.
%      PADFFT: length to which data is padded before fourier transform
%      TAPERS: supply pre-calculated tapers directly.

% This file is based on work by Adam Taylor, whose contribution is 
% greatly appreciated.

t = t(:);
[T, N] = size(x);
if T == 1 && N>1
  if numel(y) == length(y)
    x = x(:);
    y = y(:);
    [T, N] = size(x);
  end
end
if size(y,2) == 1
  y = repmat(y,[1 N]);
end

% t must be a col vector
% elements of t must be evenly spaced and increasing
% x must be a matrix with the same number of rows as t
% y must be a matrix with the same number of rows as t
% f_res is the half-width of the transform of the tapers used
%   it must be in reciprocal units of those of t
% N_fft is the length to which data is zero-padded before FFTing
% if f_star is given, coherence is estimated only at f = f_star
% this works on the columns of x and y independently
%
% f is the frequncy base, which is one-sided
% the varargouts are the sigmas

% process args

if nargin<5
  multiple_f = 1;
elseif isempty(f_star)
  multiple_f = 1;
else
  multiple_f = 0;
end
if nargin<6
  N_fft = 2.^ceil(log2(length(t)));
elseif isempty(N_fft)
  N_fft = 2.^ceil(log2(length(t)));
end
if nargin<7
  tapers = [];
end

% get the timing info, calc various scalars of interest
N = size(x,1);
N_signals = size(x,2);
dt = (t(N)-t(1))/(N-1);
fs = 1/dt;

% compute nw and K
nw = N*dt*f_res;
K = floor(2*nw-1);
if K<=0
  error('Signal too short for requested frequency resolution');
end

if isempty(tapers)
  tapers = dpss(N,nw,K);
end

tapers = reshape(tapers,[N 1 K]);

% taper and do the FFTs
x_tapered = repmat(x,[1 1 K]).*repmat(tapers,[1 N_signals 1]);
y_tapered = repmat(y,[1 1 K]).*repmat(tapers,[1 N_signals 1]);
if multiple_f
  X = fft(x_tapered,N_fft);
  Y = fft(y_tapered,N_fft);
  % drop the negative frequencies
  % all computations from here on are 'frquency-wise', do this does no 
  % harm, and saves time
  X = drop_neg_freqs(X);
  Y = drop_neg_freqs(Y);
else
  phi_star = f_star/fs;
  k = [0:(N-1)]';
  w = repmat(exp(-1i*2*pi*phi_star*k),[1 N_signals K]);
  X = sum(x_tapered.*w,1);
  Y = sum(y_tapered.*w,1);
end

% generate the frequency base
% hpfi = 'highest positive frequency index'
if multiple_f
  hpfi = ceil(N_fft/2);
  f = fs*(0:(hpfi-1))'/N_fft;
else
  f = f_star;
end

% convert to PSDs
Pxxs = (abs(X).^2)/fs;
Pyys = (abs(Y).^2)/fs;
Pxys = (X.*conj(Y))/fs;

% _sum_ across tapers (keep these around in case we need to calculate
% the take-away-one spectra for error bars)
PxxK = sum(Pxxs,3);
PyyK = sum(Pyys,3);
PxyK = sum(Pxys,3);

% convert the sum across tapers to an averge; these are our 'overall'
% spectral estimates
Pxx = PxxK/K;
Pyy = PyyK/K;
Pxy = PxyK/K;

% calculate coherence
norm = sqrt(Pxx.*Pyy+1e-50);
Cxy = Pxy ./ norm;
mag = abs(Cxy);
phase = angle(Cxy);

cohs = Pxys ./ norm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Cxy_os] = drop_neg_freqs(Cxy_ts)
% turns a two-sided coherence into a one-sided
% (i.e. it drops the negative frequencies)
% works on the the cols of Cxy_ts (i.e. along the first dimension)

S = size(Cxy_ts);
N = S(1);
S = S(2:end);
N1 = ceil(N/2);
Cxy_os = reshape(Cxy_ts, [N prod(S)]);
Cxy_os = Cxy_os(1:N1, :);
Cxy_os = reshape(Cxy_os, [N1 S]);
