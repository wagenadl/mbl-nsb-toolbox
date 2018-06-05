function phsc_channelselect(h,x)
global phsc_data

figh = igcbf;
name = iget(h, 'tag');
idx = find(name=='-');
c = str2num(name(idx+1:end));
phsc_data{figh}.c = c;
for k=1:phsc_data{figh}.C
  iset(k, 'checked', k==c);
end

phsc_redraw(figh,1);

