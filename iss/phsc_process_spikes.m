function phsc_process_spikes(figh)
global phsc_data

phsc_data{figh}.loaded = 1;
phsc_data{figh}.c = 1;

switch phsc_data{figh}.src.type
  case 'spikes'
    phsc_data{figh}.C = 1;
    phsc_data{figh}.T = max([max(phsc_data{figh}.src.spk.tms) 1]);
  case 'histo'
    phsc_data{figh}.C = size(phsc_data{figh}.src.hst,3);
    phsc_data{figh}.T = size(phsc_data{figh}.src.hst,2);
end

phsc_data{figh}.lower_thr = cell(1,phsc_data{figh}.C);
phsc_data{figh}.upper_thr = cell(1,phsc_data{figh}.C);

if isfield(phsc_data{figh}.src,'chnames')
  phsc_data{figh}.chnames = phsc_data{figh}.src.chnames;
else
  phsc_data{figh}.chnames = cell(1,phsc_data{figh}.C);
end

dT = min(60,phsc_data{figh}.T/2);

for c=1:phsc_data{figh}.C
  phsc_data{figh}.lower_thr{c} = [dT 10];
  phsc_data{figh}.upper_thr{c} = [dT 15];
end

for c=1:99
  h = ifind(sprintf('channelselect-%03i', c));
  if isempty(h)
    break;
  else
    idelete(h);
  end
end


ifigure(figh);

if phsc_data{figh}.C>1
  for c=1:phsc_data{figh}.C
    h=ibutton(sprintf('Ch%i %s',c,phsc_data{figh}.chnames{c}), ...
	@phsc_channelselect);
    iset(h, 'tag', sprintf('channelselect-%03i', c));
  end
end

iset(figh, 'title', sprintf('ISelectSpike: %s',phsc_data{figh}.ifn));

iset(figh, '*xlim0', [0 phsc_data{figh}.T/60]);
iset(figh, '*xlim', [0 phsc_data{figh}.T/60]);
iset(figh, '*ylim0', [-60 60]);
iset(figh, '*ylim', [-60 60]);

phsc_redraw(figh, 1);

