function [x,perm] = autopermute(x,dim)
% AUTOPERMUTE - Automatically permute a matrix to get non-singleton dim first
%   [y,perm] = AUTOPERMUTE(x) permutes and reshapes the (multidimensional) 
%   matrix X in such a way that the first non-singleton dimension of X (if
%   any) becomes the first dimension of Y, and all other dimensions of X are
%   lumped together into the second dimension of Y (which thus is always
%   two dimensional).
%   [y,perm] = AUTOPERMUTE(x,dim) extracts the given dimension rather than
%   the first non-singleton.
%   PERM is a structure that can be used to undo the operation using
%   z = AUTOIPERMUTE(y,perm). This works even if the length of the first
%   dimension of Y is modified first.

S=size(x);
if nargin<2
  nonsing = find(S>1);
  if isempty(nonsing)
    dim=1;
  else
    dim=nonsing(1);
  end
end
perm.ord = [dim [1:dim-1] [dim+1:length(S)]];

x = permute(x,perm.ord);
Sp = size(x);
perm.siz = Sp(2:end);
x=reshape(x,[Sp(1),prod(perm.siz)]);
[A,B] = size(x);
