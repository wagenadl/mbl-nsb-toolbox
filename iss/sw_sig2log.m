function y = sw_sig2log(x)
% SW_SIG2LOG   Convert linear spike amplitude to log representation
%    y = SW_SIG2LOG(x) converts the spike amplitude(s) X from linear scale
%    (multiplier of RMS noise) to log scale for plotting.

y = 20*sign(x).*log(1+abs(x)/15);
