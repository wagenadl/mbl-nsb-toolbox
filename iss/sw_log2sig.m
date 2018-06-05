function x = sw_log2sig(y)
% SW_LOG2SIG   Convert logarithmic spike amplitude to linear representation
%    x = SW_LOG2SIG(y) converts the spike amplitude(s) Y from log scale
%    (for plotting) to linear scale (multiplier of RMS noise).

x = 15*sign(y).*(exp(abs(y)/20)-1);
