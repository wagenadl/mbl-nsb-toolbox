function x=atoi(s)
% ATOI  Extract an integer from a string
%   x = ATOI(s) is like the libc version, except in that it returns nan if
%   S does not start with a digit (or -).
%   Exception: spaces are removed from beginning

while ~isempty(s) & (s(1)==' ' | s(1)=='	')
  s=s(2:end);
end

if length(s)==0
  x=nan;
  return;
end
  
if s(1)=='-'
  sgn=-1;
  s=s(2:end);
elseif s(1)=='+'
  sgn=1;
  s=s(2:end);
else
  sgn=1;
end

if length(s)==0 
  x=nan;
  return;
end

ok = isdigit(s);
idx=find(~ok);
if ~isempty(idx)
  s=s(1:idx(1)-1);
end

x=str2num(s) * sgn;

if isempty(x)
  x=nan;
end