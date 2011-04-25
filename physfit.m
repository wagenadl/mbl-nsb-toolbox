function [fit,yfit] = physfit(fform,x,y,sy,sx,p0,sxy)
%PHYSFIT Function fitting using errors on both X and Y
%   fit = PHYSFIT(fform,x,y,sy,sx) fits the data (X+-SX,Y+-SY) to the 
%   given functional form FFORM.
%   It returns a struct array:
%
%     fit(1) is for fitting to (X, Y);
%     fit(2) is for fitting to (X, Y+-SY);
%     fit(3) is for fitting to (X+-SX, Y+-SY).
%  
%   Entries in the array contain:
%
%     p:    fit parameters for fitting to (X+-SX, Y+-SY);
%     s:    standard errors on those parameters;
%     cov:  full covariance matrix for the fit parameters;
%     chi2: chi^2 value for the fit (not defined for fit(1));
%     ok:   1 if converged, 0 if not.
%     sok:  1 if cov and s OK, 0 if not (poorly conditioned matrix).
%     caution: cell array of textual cautions.
%
%   FFORM may be one of several standard forms:
%   
%     slope:      y = A x
%     linear:     y = A x + B
%     quadratic:  y = A x^2 + B x + C
%     poly-N:     y = A x^N + B x^(N-1) + ... + Z
%     power:      y = A x^B
%     exp:        y = A exp(B x)
%     expc:       y = A exp(B x) + C
%     log:        y = A log(x) + B
%     cos:        y = A cos(B x + C)
%   
%   Alternatively, a function form may be specified in matlab form, e.g.,
%   'A*x+B*x.^2' or 'A*cos(x).*x.^3 + B', or whatever.
%   
%   On return, p = [A B C ...].
%   
%   PHYSFIT(fform,x,y,sy,sx,p0) specifies initial parameters values. This is
%   optional for the standard forms, but required for the string form.
%   
%   Note that SY is given before SX in the parameter list. This is to
%   facilitate using PHYSFIT without errors on X, which is often useful.
%   Use SX=[] or call as PHYSFIT(fform,x,y,sy) to not specify errors on X. In
%   this case, fit(3) will not be assigned.
%   Use SY=[] or call as PHYSFIT(fform,x,y) to not specify errors at all. In
%   this case, fit(2) and fit(3) will not be assigned.
% 
%   Sometimes, X and Y observations are correlated. In that case, use
%   PHYSFIT(fform,x,y,sy,sx,p0,sxy) to specify the covariance (not its sqrt!).
%   This will only affect fit(3).
%
%   [fit,yfit] = PHYSFIT(...) also returns the best fit function values.
%   
%   PHYSFIT is Copyright (C) 2006-2009 Daniel Wagenaar <daw@caltech.edu>.
%   PHYSFIT uses LEASQR by R I Shrager, A Jutan and R Muzic as its core
%   optimizer. LEASQR.m may be obtained as part of the Octave package.

% Copyright (C) 2006 Daniel Wagenaar
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% --- Interpret arguments and check for size consistency ---
if nargin<5 | isempty(sx)
  sx=zeros(size(x));
end
if nargin<4 | isempty(sy)
  sy=zeros(size(x));
end
if nargin<6
  p0=[];
end
if nargin<7
  sxy=zeros(size(x));
end

if prod(size(sy))==1
    sy=repmat(sy,size(x));
end
if prod(size(sx))==1
    sx=repmat(sx,size(x));
end
if prod(size(sxy))==1
    sxy=repmat(sxy,size(x));
end

Sx = size(x);
Sy = size(y);
Ssy = size(sy);
Ssx = size(sx);
Ssxy = size(sxy);
LSx = length(x);
LSy = length(y);
LSsy = length(sy);
LSsx = length(sx);
LSsxy = length(sxy);

if prod(Sx) ~= LSx | prod(Sy) ~= LSy | ...
      prod(Ssy) ~= LSsy | prod(Ssx) ~= LSsx | ...
      prod(Ssxy) ~= LSsxy | ...
      LSx~=LSy | LSx~=LSsy | LSx~=LSsx | LSx~=LSsxy
  error('Inputs must be vectors of the same size.');
end

x=x(:); y=y(:); sx=sx(:); sy=sy(:); sxy=sxy(:);

% --- Parse functional form and set initial values ---
switch lower(fform)
  case 'slope'
    form = 'A*x';
    foo = @pf_slope; %@(x,p) (p*x);
    dfdx = @pf_dslope; %@(x,p) (p);
    if isempty(p0)
      p0 = sum(x.*y) ./ sum(x.^2);
    end
  case 'linear'
    form = 'A*x + B';
    foo = @pf_linear; %@(x,p) (p(1)*x + p(2));
    dfdx = @pf_dlinear; %@(x,p) (p(1));
    if isempty(p0)
      p0 = polyfit(x,y,1);
    end
  case 'quadratic'
    form = 'A*x.^2 + B*x + C';
    foo = @pf_quadratic; %@(x,p) (p(1)*x.^2 + p(2)*x + p(3));
    dfdx = @pf_dquadratic; %@(x,p) (2*p(1)*x + p(1));
    if isempty(p0)
      p0 = polyfit(x,y,2);
    end
  case 'power'
    form = 'A*x.^B'; 
    foo = @pf_power; % @(x,p) (p(1)*x.^p(2));
    dfdx = @pf_dpower; %@(x,p) (p(1)*p(2)*x.^(p(2)-1));
    if isempty(p0)
      lp = polyfit(log(x),log(y),1);
      p0 = [exp(lp(2)) lp(1)];
    end
  case 'log'
    form = 'A*log(x) + B';
    foo = @pf_log; %@(x,p) (p(1)*log(x)+p(2));
    dfdx = @pf_dlog; %@(x,p) (p(1)./x);
    if isempty(p0)
      lp = polyfit(log(x),y,1);
      p0 = [lp(1) lp(2)];
    end
  case 'exp'
    form = 'A*exp(B*x)';  
    foo = @pf_exp; %@(x,p) (p(1) * exp(p(2)*x));
    dfdx = @pf_dexp; %@(x,p) (p(1)*p(2) * exp(p(2)*x));
    if isempty(p0)
      lp = polyfit(x,log(y),1);
      p0 = [exp(lp(2))  lp(1)];
    end
  case 'expc'
    form = 'A*exp(B*x) + C';
    foo = @pf_expc; %@(x,p) (p(1) * exp(p(2)*x) + p(3));
    dfdx = @pf_dexpc; %@(x,p) (p(1)*p(2) * exp(p(2)*x));
    if isempty(p0)
      lp1 = polyfit(x,y,1);
      lp2 = polyfit(x,y,2);
      sgnB = sign(lp2(1)) * sign(lp1(1));      
      sgnA = sign(lp2(1));
      y_ = uniq(sort(y));
      if sgnA<0
	y_=y_(end:-1:1);
      end
      if length(y_)==1
	c0 = y_(1);
      else
	c0 = y_(1) - 1*(y_(2)-y_(1));
      end
      lp = polyfit(x,log((y-c0)*sgnA),1);
      p0 = [sgnA*exp(lp(2)) lp(1) c0];
    end
  case 'cos'
    form = 'A*cos(B*x + C)';
    foo = @pf_cos; %@(x,p) (p(1) * cos(p(2)*x + p(3)));
    dfdx = @pf_dcos; %@(x,p) (-p(1)*p(2) * sin(p(2)*x + p(3)));
    [p0(2),p0(3),p0(1)] = fitsine(x,y);
  otherwise
    if length(fform>=6) & strcmp(lower(fform(1:min(5,length(fform)))),'poly-')
      N = str2double(fform(6:end));
      if N ~= floor(N) | N<1 | N>20
	error('poly-n fitting only defined for integer n=1..20');
      end
      str='';
      form='';
      for n=1:N+1
	str = sprintf('%s + p(%i)*x.^%i',str,n,N+1-n);
    form = sprintf('%s + %c*x.^%i',str,'A'+(n-1),N+1-n);
      end
      foo = inline(str(4:end-5),'x','p');
      form=form(4:end-5);
      %str = [ 'foo = @(x,p) (' str(4:end-5) ');' ];
      %eval(str);
      str='';
      for n=1:N
	str = sprintf('%s + %i*p(%i)*x.^%i',str,n,N+1-n,N-n);
      end
      dfdx = inline(str(4:end-5),'x','p');
      %str = [ 'dfdx = @(x,p) (' str(4:end-5) ');' ];
      %eval(str);
      if isempty(p0)
	p0 = polyfit(x,y,N);
      end
    else
      % Arbitrary form
      form = fform;
      N = 0;
      k=1;
      fform = [ ' ' fform ' ' ];
      while k<=length(fform)
	if fform(k)>='A' & fform(k)<='Z'
	  n = 1+fform(k)-'A';
	  N = max(N,n);
	  ins = sprintf('p(%i)',n);
	  fform = [ fform(1:k-1) ins fform(k+1:end) ];
	  k=k+length(ins);
	else
	  k=k+1;
	end
      end
      if N==0
	error('No parameters found in free-form function.');
      end
      if isempty(p0)
	error('Initial values must be specified for functions specified free-form.');
      end
      if length(p0)~=N
	error('Number of parameters in free-form function must match number of initial values.');
      end
      foo = inline(fform,'x','p'); %eval([ 'foo = @(x,p) (' fform ');' ]);
      try
        z=feval(foo,mean(x),p0);
      catch
        lasterr
	error('Free-form function cannot be evaluated.');
      end
      dfdx=[];
    end
end

% Now foo is the function to be fitted, and p0 are initial values.

df = length(p0); N = length(x);

% --- Fit without SX or SY ---
wt=ones(size(sy));
[f,p,kvg,iter,corp,covp,covr,stdresid,Z,r2,rc] = ...
    leasqr(x,y,p0,foo,1e-4,1e2,wt);
fit(1).p = p';
fit(1).s = sqrt(diag(covp))';
fit(1).cov = covp;
fit(1).chi2 = nan;
fit(1).ok = kvg;
fit(1).sok = rc>sqrt(eps);
fit(1).caution={};

% --- Fit with SY but not SX ---
if max(sy)>0
  wt = 1./sy;
  [f,p,kvg,iter,corp,covp,covr,stdresid,Z,r2,rc] = ...
      leasqr(x,y,p0,foo,1e-4,1e2,wt);
  fit(2).p = p';
  fit(2).chi2 = sum((feval(foo,x,p)-y).^2.*wt.^2) ./ (N-df);
  fit(2).s = sqrt(diag(covp))' ./ sqrt(fit(2).chi2);
  fit(2).cov = covp ./ fit(2).chi2;
  fit(2).ok = kvg;
  fit(2).sok = rc>sqrt(eps);
  fit(2).caution={};
end

% --- Fit with SX and SY ---
if max(sx)>0 & max(sy)>0
  % Set the effective uncertainty to
  %
  %   sy_eff^2 = sy^2 + (df/dx)^2 * sx^2.
  
  % We iterate several times to get closer to optimal estimates of df/dx.
  
  fit(3) = fit(2);
  for iter=1:5
    if any(isnan(fit(3).p)) | any(isnan(fit(3).s)) | ~fit(3).ok | ~fit(3).sok
      p0 = fit(1).p;
    else
      p0 = fit(3).p;
    end
  
    % Following is very primitive attempt to differentiate.
    if isempty(dfdx)
      y_p = feval(foo,x+1e-10,p0);
      y_m = feval(foo,x-1e-10,p0);
      dfdx_ = (y_p-y_m) / 2e-10;
      if any(isnan(dfdx_))
	fit(3).caution{end+1} = 'Some uncertainties on X were dropped near edge of function domain.';
      end
      dfdx_(isnan(dfdx_))=0; % Simply drop uncerts that don't make sense. Hmmm?
    else
      dfdx_ = feval(dfdx,x,p0);
    end
    
    sy_eff = sqrt(sy.^2 + dfdx_.^2.*sx.^2 + dfdx_.*sxy);
  
    wt = 1./sy_eff;
    [f,p,kvg,iter,corp,covp,covr,stdresid,Z,r2,rc] = ...
	leasqr(x,y,p0,foo,1e-4,1e2,wt);
    if kvg | iter==1
      fit(3).p = p';
      fit(3).chi2 = sum((feval(foo,x,p)-y).^2.*wt.^2) ./ (N-df);
      fit(3).s = sqrt(diag(covp))' ./ sqrt(fit(3).chi2);
      fit(3).cov = covp ./ fit(3).chi2;
      fit(3).ok=kvg;
      fit(3).sok=rc>sqrt(eps);
    end
  end
else
  sy_eff = [];
end

for k=1:length(fit)
  if ~fit(k).ok
    fit(k).caution{end+1} = 'Least squares failed to converge. Parameters not valid.';
  end
  if ~fit(k).sok
    fit(k).caution{end+1} = 'Poorly conditioned matrix in variance calculation. Uncertainties unreasonably large.';
  end
end

for k=1:length(fit)
    fit(k).form = form;
end

if nargout>=2
    for k=1:length(fit)
        yfit{k} = feval(foo,x,fit(k).p);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = pf_slope(x,p)
y = p*x;

function y = pf_dslope(x,p)
y = p;

function y = pf_linear(x,p)
y = p(1)*x + p(2);

function y = pf_dlinear(x,p)
y = p(1);

function y = pf_quadratic(x,p)
y = p(1)*x.^2 + p(2)*x + p(3);

function y = pf_dquadratic(x,p)
y = 2*p(1)*x + p(2);

function y = pf_power(x,p)
y = p(1)*x.^p(2);

function y = pf_dpower(x,p)
y = p(1)*p(2)*x.^(p(2)-1);

function y = pf_log(x,p)
y = p(1)*log(x)+p(2);

function y = pf_dlog(x,p)
y = p(1)./x;

function y = pf_exp(x,p)
y = p(1) * exp(p(2)*x);

function y = pf_dexp(x,p)
y = p(1)*p(2) * exp(p(2)*x);

function y = pf_expc(x,p)
y = p(1) * exp(p(2)*x) + p(3);

function y = pf_dexpc(x,p)
y = p(1)*p(2) * exp(p(2)*x);

function y = pf_cos(x,p)
y = p(1) * cos(p(2)*x + p(3));

function y = pf_dcos(x,p)
y = -p(1)*p(2) * sin(p(2)*x + p(3));