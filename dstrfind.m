function idx = strfind(a,b)
% k = STRFIND(a,b) returns the starting indices of any occurrences
% of string B in string A. Unlike matlab's FINDSTR, returns [] if 
% A is shorter than B.
if length(a)<length(b)
  idx=[];
else
  idx=findstr(a,b);
end
