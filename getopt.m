function kv = getopt(opts,varargin)
% GETOPT Condense function options into a struct.
%    kv = GETOPT(opts,...) returns a structure with fields OPTS and values
%    based on ... 
%    Options occurring in ... but not in OPTS cause a warning, unless OPTS is [].
%    Options not named in ... are set to [].
%    Option names may be abbreviated, unless OPTS is [].
%    Option names are always converted to lower case.
%
%    For instance,
%      kv = GETOPT({'foo', 'bar', 'longoption'}, 'foo', 3, 'longo', 'x') 
%    returns
%      KV = foo: 3
%           bar: []
%           longoption: 'x'.
%
%    Instead of a cell array, OPTS may be a single string with options 
%    separated by spaces. The magic option name '+' prevents warnings
%    for unknown options.
%
%    GETOPT may be called as in GETOPT('foo bar', varargin) or as in
%    GETOPT('foo bar', varargin{:}).
%
%    Defaults may be specified in OPTS. For instance:
%      GETOPT('foo=3 bar=''yes''', varargin).
%    Only simple numbers and strings may be passed this way.

if iscell(varargin) 
  if length(varargin)==1
    if iscell(varargin{1})
      varargin=varargin{1};
    end
  end
  if length(varargin)==1
    if isstruct(varargin{1})
      kv = varargin{1};
      return    
    end
  end
end

if mod(length(varargin), 2)==1
  error('getopt: options and values must come in pairs');
end

if isstruct(opts)
  kv=opts;
  kv.getopt__version=1;  
  for k=1:2:length(varargin)
    if isfield(opts,varargin{k})
      kv.(varargin{k}) = varargin{k+1};
    end
  end
  return
end

if ischar(opts)
  if ~isempty(opts)
    opts = strsplit(opts);
  end
end

kv.getopt__version=1;
accept_any = 0;
for n=1:length(opts)
  if strcmp(opts{n},'+')
    accept_any=1;
  else
    opts{n} = lower(opts{n});
    idx = find(opts{n}=='=');
    if isempty(idx)
      val=[];
    else
      idx=idx(1);
      id2=find(opts{n}=='''');
      if length(id2)<2
        id2=[0 0];
      end
      if id2(1)==idx+1
        val=opts{n}(id2(1)+1:id2(2)-1);
      else
        val=str2num(opts{n}(idx+1:end));
      end
      opts{n} = opts{n}(1:idx-1);
    end
    kv.(opts{n})=val;
    %kv = setfield(kv,opts{n},val);
  end
end

for n=1:2:length(varargin)
  k = lower(varargin{n});
  v = varargin{n+1};
  %if isempty(v)
  %  continue;
  %end
  if isempty(opts)
    kv.(k) = v;
    %kv = setfield(kv,k,v);
  else
    idx = strmatch(k,opts,'exact');
    if isempty(idx)
      idx = strmatch(k,opts);
    end
    if isempty(idx)
      if accept_any
	kv.(k) = v;%	kv = setfield(kv,k,v);
      else
	warning(sprintf('Unknown option "%s" - ignored',k));
      end
    elseif length(idx)>1
      warning(sprintf('Ambiguous option "%s" - ignored',k));
    else
      kv.(opts{idx}) = v;
      %kv = setfield(kv,opts{idx},v);
    end
  end
end
