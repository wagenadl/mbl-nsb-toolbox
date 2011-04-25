function [w,h] = screensize
% SCREENSIZE   Return width and height of screen
%    [w,h] = SCREENSIZE returns the width and height of the screen in pixels.
%    wh = SCREENSIZE returns it as a 1x2 vector.

u = get(0, 'units');
set(0, 'units', 'pixels');

xywh = get(0, 'screensize');
w = xywh(3);
h = xywh(4);

set(0, 'units',u);

if nargout<2
  w = [w h];
  clear h;
end
