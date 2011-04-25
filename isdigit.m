function b=isdigit(s)
% ISDIGIT  True if a character is a digit.
%   b = ISDIGIT(s) returns a logical vector stating whether the characters 
%   in S are digits.
b = s>='0' & s<='9';

