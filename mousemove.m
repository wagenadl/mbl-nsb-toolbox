function [xy0,xy1] = mousemove(foo,varargin)
% MOUSEMOVE  Repeatedly call a function until mouse is released
%   xy1 = MOUSEMOVE(foo,args,...) repeatedly calls FOO (a function 
%   handle) with arguments H, XY0, XY1, ARGS, until the mouse is released.
%   XY0 is the mouse position at the start of the drag, XY1 is the current
%   (or final) position. (H is the GCA at time of call.)
%   [xy0, xy1] = MOUSEMOVE(...) returns initial position as well.
%   Throughout and after the drag, the appdata 'mousemove_significant' 
%   is set true for object H if a move of more than 2 pixels is detected.
%   The appdata 'mousemove__recurse' on the parent figure is set true
%   throughout the move, and can be used to ensure the function is not
%   nested. 

h = gca;
f = gcf;
xy0 = get(h,'currentpoint'); xy0=xy0(1,1:2);

if getappdata(f,'mousemove__recurse')
  fprintf(1,'Warning: MOUSEMOVE called recursively.\n');
  if nargout>=2
    xy1=xy0;
  end
  return
end

setappdata(f,'mousemove__recurse',1);

setappdata(f,'mousemove__oldmove',get(f,'windowbuttonmotionfcn'));
setappdata(f,'mousemove__oldup',get(f,'windowbuttonupfcn'));
setappdata(f,'mousemove__foo',foo);
setappdata(f,'mousemove__xy0',xy0);
setappdata(f,'mousemove__args',varargin);
setappdata(f,'mousemove__axesh',h);
setappdata(h,'mousemove_significant',0);

set(f,'windowbuttonmotionfcn',@mousemove_move);
set(f,'windowbuttonupfcn',@mousemove_up);

uiwait(f);

xy1 = get(h,'currentpoint'); xy1=xy1(1,1:2);

set(f,'windowbuttonmotionfcn',getappdata(f,'mousemove__oldmove'));
set(f,'windowbuttonupfcn',getappdata(f,'mousemove__oldup'));

if nargout<2
  xy0=xy1;
  clear xy1;
end

setappdata(f,'mousemove__recurse',0);

%---------------------------------------------------------------------
function mousemove_move(f,x)
h=getappdata(f,'mousemove__axesh');
xy1 = get(h,'currentpoint'); xy1=xy1(1,1:2);
xy0 = getappdata(f,'mousemove__xy0');
signif = getappdata(h,'mousemove_significant');
if ~signif
  signif = sum(((xy1-xy0)./onepixel).^2) > 2.^2;
  setappdata(h,'mousemove_significant',signif);
end
args = getappdata(f,'mousemove__args');
feval(getappdata(f,'mousemove__foo'),...
    h, getappdata(f,'mousemove__xy0'), xy1, args{:});

function mousemove_up(f,x)
uiresume(f);
