function coh = multitaper_coherence(tt, y_ref, y_sig, varargin)
% VSCOPE_COHERENCE - Multitaper coherence estimate for vscope
%    coh = VSCOPE_COHERENCE(tt, y_ref, y_sig) calculates multitaper coherence
%    estimates for the signals in the columns of Y_SIG wrt the reference
%    signal in Y_REF.
%    coh = VSCOPE_COHERENCE(tt, y_ref, y_sig, key, value, ...) specifies
%    additional parameters:
%       df - frequency resolution (in Hz if tt is in seconds). Default is
%            0.667 Hz.
%       alpha - confidence interval in units of alpha. (alpha=0.05
%            for 95% confidence interval.)
%       ci - confidence interval in units of sigma. Overrides alpha.
%       f - single frequency at which to evaluate. Default is [] for
%           all frequencies.
%    Return value is a structure with fields:
%       f - frequency vector (in Hz if t_sig is in seconds) (Fx1 vector)
%       coh - coherence estimates for each of the signals (FxN complex matrix)
%       mag - absolute values of above
%       phase - phase of above
%       sd_phase - circular standard deviation
%       mag_lo - low end of magnitude confidence interval
%       mag_hi - high end of same
%       phase_lo - low end of phase confidence interval
%       phase_hi - high end of same

% This file is part of VScope. (C) Daniel Wagenaar 2008-1017.

% VScope is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% VScope is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with VScope.  If not, see <http://www.gnu.org/licenses/>.

kv = getopt('df=2/3 alpha=0.05 ci=[] f=[]', varargin);

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

if isempty(kv.f) 
  [coh.f, coh.mag, coh.phase, coh.cohs] ...
      = coh_mtm1(tt, y_sig, y_ref, kv.df);
else
  [coh.f, coh.mag, coh.phase, coh.cohs] ...
      = coh_mtm1(tt, y_sig, y_ref, kv.df, kv.f);
end

if isempty(kv.ci)
  kv.ci = norminv(1 - kv.alpha/2);
end
K = size(coh.cohs,3);
coh.re = mean(real(coh.cohs), 3);
coh.sd_re = std(real(coh.cohs), [], 3) ./ sqrt(K);
coh.im = mean(imag(coh.cohs), 3);
coh.sd_im = std(imag(coh.cohs), [],3) ./ sqrt(K);

purephase = coh.cohs ./ abs(coh.cohs);
coh.sd_phase = sqrt(-2*log(abs(mean(purephase, 3))));

% To get an estimate of uncertainties, let's project onto axis through
% average.
coh0 = real(coh.cohs./exp(1i*coh.phase));
% Now, mean(coh0, 3) == mag.
K = size(coh0, 3);
coh.sd_mag = std(coh0, [], 3) ./ sqrt(K);

coh.mag_lo = max(coh.mag - kv.ci*coh.sd_mag, 0);
coh.mag_hi = min(coh.mag + kv.ci*coh.sd_mag, 1);

coh.phase_lo = coh.phase - min(kv.ci*coh.sd_phase, pi);
coh.phase_hi = coh.phase + min(kv.ci*coh.sd_phase, pi);
