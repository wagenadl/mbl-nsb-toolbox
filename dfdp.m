% Copyright (C) 1992-1994 Richard Shrager
% Copyright (C) 1992-1994 Arthur Jutan
% Copyright (C) 1992-1994 Ray Muzic
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

function prt=dfdp(x,f,p,dp,func)
% numerical partial derivatives (Jacobian) df/dp for use with leasqr
% --------INPUT VARIABLES---------
% x=vec or matrix of indep var(used as arg to func) x=[x0 x1 ....]
% f=func(x,p) vector initialsed by user before each call to dfdp
% p= vec of current parameter values
% dp= fractional increment of p for numerical derivatives
%      dp(j)>0 central differences calculated
%      dp(j)<0 one sided differences calculated
%      dp(j)=0 sets corresponding partials to zero; i.e. holds p(j) fixed
% func=string naming the function (.m) file
%      e.g. to calc Jacobian for function expsum prt=dfdp(x,f,p,dp,'expsum')
%----------OUTPUT VARIABLES-------
% prt= Jacobian Matrix prt(i,j)=df(i)/dp(j)
%================================

m=size(x,1); if (m==1), m=size(x,2); end  %# PAK: in case #cols > #rows
n=length(p);      %dimensions
ps=p; prt=zeros(m,n);del=zeros(n,1);       % initialise Jacobian to Zero
for j=1:n
      del(j)=dp(j) .*p(j);    %cal delx=fract(dp)*param value(p)
      if p(j)==0
           del(j)=dp(j);     %if param=0 delx=fraction
      end
      p(j)=ps(j) + del(j);
      if del(j)~=0, f1=feval(func,x,p);
           if dp(j) < 0, prt(:,j)=(f1-f)./del(j);
           else
                p(j)=ps(j)- del(j);
                prt(:,j)=(f1-feval(func,x,p))./(2 .*del(j));
           end
      end
      p(j)=ps(j);     %restore p(j)
end
return
