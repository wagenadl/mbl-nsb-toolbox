function psd = multitaper_specgram(t_sig, y_sig, varargin)
% MULTITAPER_PSD - Multitaper spectrogram estimate
%    psd = MULTITAPER_SPECGRAM(t_sig, y_sig) calculates multitaper
%    spectrogram estimates for the signals in the columns of Y_SIG. 
%    By default, 8 windows with 50% overlap are generated.
%    psd = MULTITAPER_SPECGRAM(t_sig, y_sig, key, value, ...) specifies
%    additional parameters:
%       df - frequency resolution (in Hz if t_sig is in seconds). Default
%            is 0.333 Hz.
%       nw - number of time windows (default: 8)
%       overlap - overlap fraction (default: 0.50, i.e., each window
%            overlaps 50% with its predecessor)
%    Return value is a structure with fields:
%       f - frequency vector (in Hz if t_sig is in seconds) (Fx1 vector)
%       t - time vector (center of windows) (Wx1 vector)
%       psd - power estimates for each of the signals (FxWxN matrix) 
%       sd - uncertainty on those estimates (FxWxN matrix)
%       estimates - raw estimates on which PSD and SD are based
%   Each window is individually Hamming-windowed and a linear trend
%   is subtracted.

% The core of this code was adapted from an original by Adam Taylor, whose
% contribution is gratefully acknowledged.

kv = getopt('df=1/3 nw=8 overlap=.5 func=''hamming''', varargin);

if numel(t_sig) ~= length(t_sig)
    error('T_SIG must be a vector');
end
if std(diff(t_sig)) > .001*mean(diff(t_sig))
  error('T_SIG must be uniformly increasing');
end
if numel(y_sig) == length(y_sig)
    % Y_SIG is a vector, so let's relax about 1xT vs Tx1
    y_sig = y_sig(:);
end
t_sig = t_sig(:); % Force T_SIG to be Tx1
TT = length(t_sig);

if kv.nw<2
  error('NW must be at least two. Otherwise, use MULTITAPER_PSD.')
end

N = size(y_sig, 2); % Number of signal vectors
T = kv.nw;
psd.t = zeros(T, 1);

% If I have TT time points and T windows, how many data points per window?
% Let window t start at A*t and end at B+A*t. We want B+A*T = TT and
% B - A = overlap * B, i.e., (1-overlap) * B = A.
% So A/(1-overlap) + A*T = TT, i.e., A*(T+1/(1-overlap)) = TT
A = TT/(T + 1/(1 - kv.overlap));
B = round(A/(1-kv.overlap));
for t=1:T
  ii = [1:B] + round(A*(t-1));
  if ii(end)>TT
    ii = ii - (ii(end)-TT);
  end
  psd.t(t) = mean(t_sig(ii));
  sig = hamming(B) .* detrend(y_sig(ii,:));
  [f, pp, est] = pds_mtm0(t_sig(ii), sig, kv.df);
  K = size(est, 3); % number of tapers
  F = length(f);
  if t==1
    psd.f = f;
    psd.psd = zeros(F, T, N);
    psd.estimates = zeros(F,T,N,K);
  end
  psd.psd(:,t,:) = reshape(pp, [F 1 N]);
  psd.estimates(:,t,:,:) = reshape(est, [F 1 N K]);
end

psd.sd = std(psd.estimates,[],4) ./ sqrt(K);
psd.estimates = squeeze(psd.estimates);
