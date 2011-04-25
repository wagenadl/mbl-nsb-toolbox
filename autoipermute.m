function x = autoipermute(x,perm)
% AUTOIPERMUTE - Inverse operation of AUTOPERMUTE
%   z = AUTOIPERMUTE(y,perm) reverses the operation of
%   [y,perm] = AUTOPERMUTE(x). This works even if the length of the first
%   dimension of Y is modified first.

S = size(x);
if S(2)==prod(perm.siz)
  x = reshape(x,[S(1) perm.siz]);
end
x = ipermute(x,perm.ord);