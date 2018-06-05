function phsc_move(h, but)
tag = iget(h, 'tag');
idx = iget(h, '*index');
xy0 = iget(h, '*xy0');

x = xy0(1)/60;
y = sw_sig2log(xy0(2));

dxy = iget(igca, 'currentpoint') - iget(igca, 'downpoint');

x = x + dxy(1);
y = y + dxy(2);

x1 = x*60;
y1 = sw_log2sig(y);

global phsc_data
figh = igcf;
c=phsc_data{figh}.c;

switch tag
  case {'lowerline', 'lowerdots' }
    phsc_data{figh}.lower_thr{c}(idx, :) = [x1 y1];
  case {'upperline', 'upperdots' }
    phsc_data{figh}.upper_thr{c}(idx, :) = [x1 y1];
end

phsc_redraw(figh, 0);
