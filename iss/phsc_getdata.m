function gdspk = phsc_getdata(figh)
global phsc_data

gdspk.tms=[];
gdspk.amp=[];

if strcmp(phsc_data{figh}.src.type,'spikes')
  for c=1:phsc_data{figh}.C
    idx = find(phsc_data{figh}.src.spk.chs==c);
    tt = phsc_data{figh}.src.spk.tms(idx);
    yy = phsc_data{figh}.src.spk.hei(idx);
    sigm=median(abs(yy(yy~=0)))/10;
    yy = yy/sigm;
    
    x = phsc_data{figh}.lower_thr{c}(:,1);
    y = phsc_data{figh}.lower_thr{c}(:,2);
    [x,ord]=sort(x);
    y = y(ord);
    x=[min([0 min(x)-10]); x(:); max([max(tt) max(x)])+10] ;
    y=[y(1); y(:); y(end)];
    lower_thr = interp1(x,y,tt,'linear');
  
    x = phsc_data{figh}.upper_thr{c}(:,1);
    y = phsc_data{figh}.upper_thr{c}(:,2);
    [x,ord]=sort(x);
    y = y(ord);
    x=[min([0 min(x)-1]); x(:); max([max(tt) max(x)])+10];
    y=[y(1); y(:); y(end)];
    upper_thr = interp1(x,y,tt,'linear');
    
    if mean(upper_thr)<mean(lower_thr)
      ll=lower_thr;
      lower_thr=upper_thr;
      upper_thr=ll;
    end
  
    idx = idx(find(yy>lower_thr & yy<upper_thr));
    
    gdspk.tms = phsc_data{figh}.src.spk.tms(idx);
    gdspk.amp = phsc_data{figh}.src.spk.hei(idx);
  end
end

