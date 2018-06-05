function phsc_press(h, but)
if but~=1
  return;
end

tag = iget(h, 'tag');
act = 0;

global phsc_data
figh = igcf;
c=phsc_data{figh}.c;

switch tag
  case { 'lowerline', 'lowerdots' }
    xx = phsc_data{figh}.lower_thr{c}(:,1);
    yy = phsc_data{figh}.lower_thr{c}(:,2);
    act = 1;
  case { 'upperline', 'upperdots' }
    xx = phsc_data{figh}.upper_thr{c}(:,1);
    yy = phsc_data{figh}.upper_thr{c}(:,2);
    act = 1;
end

if ~act
  return;
end

xy = iget(igca, 'currentpoint');
x = xy(1) * 60;
y = sw_log2sig(xy(2));

switch tag
  case { 'upperline', 'lowerline' }
    ii = findfirst_ge(xx, x);
    if ii>0
      xx=[xx(1:ii-1); x; xx(ii:end)];
      yy=[yy(1:ii-1); y; yy(ii:end)];
    else
      xx=[xx; x];
      yy=[yy; y];
      ii=length(xx);
    end
  case { 'upperdots', 'lowerdots' }
    y_ = sw_sig2log(yy);
    x_ = xx/60;
    ii = argmin((x_-xy(1)).^2 + (y_-xy(2)).^2);
end

iset(h, '*index', ii);
iset(h, '*xy0', [xx(ii) yy(ii)]);

switch tag
  case 'lowerline'
    phsc_data{figh}.lower_thr{c} = [xx, yy];
    phsc_redraw(figh, 0);
  case 'upperline'
    phsc_data{figh}.upper_thr{c} = [xx, yy];
    phsc_redraw(figh, 0);
end

