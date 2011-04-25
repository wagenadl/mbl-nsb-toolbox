function [ipk,itr,i0pk,i1pk,i0tr,i1tr] = schmittpeak(yy, thr_up, thr_dn)
% SCHMITTPEAK - Finds peaks and troughs in data after Schmitt triggering
%    ipk = SCHMITTPEAK(yy, thr_up, thr_dn) Schmitt triggers the data YY at
%    thresholds THR_UP and THR_DN, and returns the indices of the peaks between
%    each pair of threshold crossings. If THR_DN is not given, it defaults 
%    to -THR_UP.
%    [ipk,itr] = SCHMITTPEAK(...) also returns the indices of the troughs.
%    [ipk,itr,i0pk,i1pk,i0tr,i1tr] = SCHMITTPEAK(...) the indices of the starts
%    and ends of peaks and troughs.
%    Note: if the trace YY starts above THR_UP (or ends above THR_DN), the first
%    (or last) partial peak is not considered.

if nargin<3
  thr_dn = -thr_up;
end

T=length(yy);

[iup,idn] = schmitt(yy, thr_up, thr_dn, 2);

i0pk = iup;
i1pk = idn;
if 1
  if length(i0pk)>0 & i0pk(1)==1
    i0pk = i0pk(2:end);
    i1pk = i1pk(2:end);
  end
  if length(i1pk)>0 & i1pk(end)==T+1
    i0pk = i0pk(1:end-1);
    i1pk = i1pk(1:end-1);
  end
end

K=length(i0pk);
ipk=zeros(K,1);
for k=1:K
  [dummy,ii] = max(yy(i0pk(k):i1pk(k)-1));
  ipk(k) = i0pk(k)-1+ii;
end
  
if nargout>=2
  i0tr = idn(1:end-1);
  i1tr = iup(2:end);
  
  K=length(i0tr);
  itr=zeros(K,1);
  for k=1:K
    [dummy,ii] = min(yy(i0tr(k):i1tr(k)-1));
    itr(k) = i0tr(k)-1+ii;
  end
  if nargout<5
    clear i0tr
    clear i1tr
  end
  if nargout<3
    clear i0pk
    clear i1pk
  end
end  
