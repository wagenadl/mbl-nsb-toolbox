function phsc_redraw(figh, graphtoo)
global phsc_data

ax = ifind(figh, 'graph');
xlim = iget(figh, '*xlim');
ylim = iget(figh, '*ylim');
iset(ax, 'xlim', xlim);
iset(ax, 'ylim', ylim);

if graphtoo
  c = phsc_data{figh}.c;
  switch phsc_data{figh}.src.type
    case 'spikes'
      idx = find(phsc_data{figh}.src.spk.chs==c);
      xx = phsc_data{figh}.src.spk.tms(idx) / 60;
      yy = phsc_data{figh}.src.spk.hei(idx);
      sigm=median(abs(yy(yy~=0)))/10;
      yy = sw_sig2log(yy/sigm);
    case 'histo'
      error('histogram data not yet supported in iselectspike');
      % yy = sw_sig2log(phsc_data{figh}.src.hst_xx);
      % xx = [1:phsc_data{figh}.T]/60;
      % nn = phsc_data{figh}.src.hst(:,:,c);
      % 
      % a=axis;
      % xidx = find(xx>=a(1) & xx<=a(2));
      % yidx = find(yy>=a(3) & yy<=a(4));
      % xx=xx(xidx);
      % yy=yy(yidx);
      % nn=nn(yidx,xidx);
      % 
      % scl = ceil(length(xx) / phsc_data{figh}.axesw);
      % bin = floor(length(xx)/scl);
      % xx=mean(reshape(xx(1:scl*bin),[scl bin]),1);
      % nn=squeeze(sum(reshape(nn(:,1:scl*bin),[length(yy) scl bin]),2));
      % nn = gsmooth(gsmooth(nn,.05)',.5)';
  end
  
  iset(ifind(ax, 'trace'), 'xdata', xx, 'ydata', yy);
  iset(ax, 'xlabel', 'Time (min)');
  iset(ax, 'ylabel', 'Spike Amplitude');
end

c=phsc_data{figh}.c;
xx = phsc_data{figh}.lower_thr{c}(:,1) / 60;
yy = sw_sig2log(phsc_data{figh}.lower_thr{c}(:,2));

h = ifind(ax, 'lowerdots');
iset(h, 'xdata', xx, 'ydata', yy);

h = ifind(ax, 'lowerline');
iset(h, 'xdata',[xlim(1); xx; xlim(2)], 'ydata', [yy(1); yy; yy(end)]);

xx = phsc_data{figh}.upper_thr{c}(:,1) / 60;
yy = sw_sig2log(phsc_data{figh}.upper_thr{c}(:,2));
h = ifind(ax, 'upperdots');
iset(h, 'xdata', xx, 'ydata', yy);
h = ifind(ax, 'upperline');
iset(h, 'xdata', [xlim(1); xx; xlim(2)], 'ydata', [yy(1); yy; yy(end)]);
