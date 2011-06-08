function [dat,tms] = loadephys(fn)
% LOADEPHYS - Load electrophysiology traces
%    dat = LOADEPHYS(fn) loads the electrophysiology file FN and returns
%    the data as DAT as an LxN array, where L is the length of the recording
%    and N is the number of channels recorded.
%    [dat,tms] = LOADEPHYS(fn) returns a vector of time stamps as well.

if ~exist(fn)
  error(sprintf('LOADEPHYS: File "%s" not found\n',fn));
end

idx = find(fn == '.');
if isempty(idx)
  ext='';
  fnbase=fn;
else
  idx=idx(end);
  ext=fn(idx+1:end);
  fnbase=fn(1:idx-1);
end

switch ext
  case 'abf'
    % pClamp10 file
    [ dat, aux] = readabf(fn);
    len=size(dat,1);
    if nargout>=2
      tms=[1:len]'*aux.dt_s;
    end
    
    skp1=std(diff(dat(1:2:1e3,1)));
    skp2=std(diff(dat(2:2:1e3,1)));
    skp=std(diff(dat(1:1e3,1)));
    if skp1<skp & skp2<skp
      % This must be interleaved min/max data
      fprintf(1,'Assuming min/max data; returning only greatest absolute values\n');
      C=size(dat,2);
      for c=1:C
	mn=dat(1:2:end,c);
	mx=dat(2:2:end,c);
	usemx=abs(mx)>abs(mn);
	mn(usemx) = mx(usemx);
	dat(1:2:end,c) = mn;
      end
      dat=dat(1:2:end,:);
      if nargout>=2
        tms=tms(1:2:end);
      end
    end
  case 'daq'
    % Matlab DAQ file
    if nargout>=2
      if exist('daqread')
	[dat,tms]=daqread(fn);
      else
	error('This version of matlab/octave does not support DAQREAD');
      end
    else
      dat = daqread(fn);
    end
  case 'xml'
    % vsdscope / vscope file
    dat = vsdload(fn);
    if nargout>=2
      tms=[1:size(dat.analog.dat,1)]' / dat.analog.info.rate_hz;
    end
    dat = dat.analog.dat;
  case 'escope'
    % Python EScope file
    fd = fopen([fnbase '.txt']);
    clear str
    while 1
      txt = fgets(fd);
      if ischar(txt)
        while txt(end)<' '
          txt=txt(1:end-1);
        end
        eval(['str.' txt ';']);
      else
        break
      end
    end
    fclose(fd);
    fd = fopen([fnbase '.dat']);
    dat = fread(fd,[str.nchannels,inf],'double')';
    fclose(fd);
    if nargout>=2
      tms=[1:size(dat,1)]'/str.rate_hz;
    end
  otherwise
    error('loadephys: Unknown file format');
end

