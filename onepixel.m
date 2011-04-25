function [x,y] = onepixel(h)
% ONEPIXEL   Distance in graph coordinates corresponding to one pixel.
%   [x,y] = ONEPIXEL returns the distance in graph coordinates that 
%   corresponds to one pixel on screen.
%   [x,y] = ONEPIXEL(h) looks at axes H rather than current axes.
%   xy = ONEPIXEL(...) returns results in a single 1x2 variable.

if nargin<1
  h=gca;
end

uni = get(h,'units');
set(h,'units','pixels');
abox=get(h,'position');
set(h,'units',uni);
ax=[get(h,'xlim') get(h,'ylim')];
sc = abox(3:4);
x = [ax(2)-ax(1), ax(4)-ax(3)] ./ sc;
if nargout>1
  y = x(2);
  x = x(1);
end

