function [idx, idx2] = matchnearest(tt1, tt2, maxdt)
% MATCHNEAREST - Find matching events in two point processes
%   idx = MATCHNEAREST(tt1, tt2) returns a vector in which the k-th
%   element indicates which event in point process TT2 occured most
%   closely to the k-th event in point process TT1.
%   idx = MATCHNEAREST(tt1, tt2, maxdt) specifies a maximum time interval
%   beyond which matches cannot be declared.
%   Events that do not have a match result in a zero entry in the IDX.
%
%   Alternatively, [idx1, idx2] = MATCHNEAREST(tt1, tt2) returns two
%   vectors, such that TT1(IDX1) and TT2(IDX2) are matching
%   events. That means you can create a scatter plot of latencies with
%   something like:
%
%     plot(tt2(idx2) - tt1(idx1), '.');
%
%   Note that this function does not guarantee that the matching is
%   one-to-one: Although at most event in TT2 can be matched to a
%   given even in TT1, it is possible that an event in TT2 is matched
%   to multiple events in TT1. See MATCHNEAREST2 if this is
%   undesirable.

if nargin<3
  maxdt = inf;
end

N = length(tt1);
idx = 0*tt1;
for n=1:N
  t0 = tt1(n);
  dt = tt2 - t0;
  [mindt, id] = min(abs(dt));
  if mindt<maxdt
    idx(n) = id;
  end
end

if nargout==2
  idx2 = idx(idx>0);
  idx = find(idx>0);
end
