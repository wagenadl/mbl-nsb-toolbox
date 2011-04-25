function yn = endswith(str,sub)
% ENDSWITH - Returns true if a string ends with a given substring
%    yn = ENDSWITH(str,sub) returns true if the end of STR equals SUB.

if length(str)<length(sub)
  yn=0;
elseif strcmp(str(end-length(sub)+1:end),sub)
  yn=1;
else
  yn=0;
end
