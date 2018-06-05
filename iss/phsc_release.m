function phsc_release(h, but)
if but~=1
  return;
end

tag = iget(h, 'tag');
act = 0;

global phsc_data
figh = igcf;
c=phsc_data{figh}.c;

xx = phsc_data{figh}.upper_thr{c}(:,1);
yy = phsc_data{figh}.upper_thr{c}(:,2);
nn = find(xx(2:end)<xx(1:end-1));
if ~isempty(nn)
  act = 1;
  xx(nn) = (xx(nn+1)+xx(nn))/2; xx(nn+1)=[];
  yy(nn) = (yy(nn+1)+yy(nn))/2; yy(nn+1)=[];
  phsc_data{figh}.upper_thr{c} = [xx yy];
end

xx = phsc_data{figh}.lower_thr{c}(:,1);
yy = phsc_data{figh}.lower_thr{c}(:,2);
nn = find(xx(2:end)<xx(1:end-1));
if ~isempty(nn)
  act = 1;
  xx(nn) = (xx(nn+1)+xx(nn))/2; xx(nn+1)=[];
  yy(nn) = (yy(nn+1)+yy(nn))/2; yy(nn+1)=[];
  phsc_data{figh}.lower_thr{c} = [xx yy];
end

if act
  phsc_redraw(figh, 0);
end

