function phsc_loaddat(figh, spk)
global phsc_data


phsc_data{figh}.ifn = 'data';
phsc_data{figh}.src.spk.tms = spk.tms;
phsc_data{figh}.src.spk.chs = 1+0*spk.tms;
phsc_data{figh}.src.spk.hei = spk.amp;

phsc_data{figh}.src.type = 'spikes';

phsc_process_spikes(figh);
