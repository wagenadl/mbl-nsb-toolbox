function gdspk = iselectspike(spk)
% ISELECTSPIKE - Interactive posthoc spike classification
%    gdspk = SELECTSPIKE(spk) plots a raster of the spikes in SPK (previously
%    detected using SUC2SPIKE) and lets the user interactively select
%    which spikes belong to the neuron of interest.
%
%    Place the green and blue lines around the relevant dots (it does not
%    matter which one is above and which one is below). More handles
%    can be made by dragging the line; handles can be removed by dragging
%    them past the next handle.

global phsc_data

[w,h]=screensize;
figw = w/2-40;
figh = h/2-80;
f=ifigure;
iset(f, 'position',[20 40], 'size', [figw figh], ...
    'title', 'ISelectSpike');

iset(igca(), 'tag', 'graph');

phsc_data{f}.loaded=0;
phsc_data{f}.figw = figw;
phsc_data{f}.figh = figh;

h = ibutton('Done', @phsc_done);
iset(h, 'tag', 'done');
% ibutton('Zoom', @phsc_zoom);

% icallback(igca(), 'buttondownfcn', @phsc_click);

h = ipoints([0 1], [0 0]);
iset(h, 'tag', 'trace', 'color', [0 0 0], 'markersize', 2);
% icallback(h, 'buttondownfcn', @phsc_click);

h = iplot([0 1], [0 0]);
iset(h, 'color', [0 0 1], 'linewidth', 2, 'tag', 'lowerline');
icallback(h, 'buttonmotionfcn', @phsc_move);
icallback(h, 'buttondownfcn', @phsc_press);
icallback(h, 'buttonupfcn', @phsc_release);

h = ipoints(.5, 0);
iset(h, 'color', [0 0 1], 'markersize', 10, 'tag', 'lowerdots');
icallback(h, 'buttonmotionfcn', @phsc_move);
icallback(h, 'buttondownfcn', @phsc_press);

h = iplot([0 1], [1 1]);
iset(h, 'color', [0 1 0], 'linewidth', 2, 'tag', 'upperline');
icallback(h, 'buttonmotionfcn', @phsc_move);
icallback(h, 'buttondownfcn', @phsc_press);
icallback(h, 'buttonupfcn', @phsc_release);

h = ipoints(.5, 1);
iset(h, 'color', [0 1 0], 'markersize', 10, 'tag', 'upperdots');
icallback(h, 'buttonmotionfcn', @phsc_move);
icallback(h, 'buttondownfcn', @phsc_press);

iset(f, '*xlim0', iget(igca(), 'xlim'));
iset(f, '*xlim', iget(igca(), 'xlim'));
iset(f, '*ylim0', iget(igca(), 'xlim'));
iset(f, '*ylim', iget(igca(), 'xlim'));

phsc_loaddat(f, spk);

iset(f, '*completed', 0);

while 1
  iwait(f);
  cancel=0;
  done=0;
  try
    done = iget(f, '*completed');
  catch
    cancel = 1;
  end
  if done
    break
  end
  if cancel
    break
  end
end

if done
  gdspk = phsc_getdata(f);
  iclose(f);
else
  gdspk.tms = [];
  gdspk.amp = [];
end


