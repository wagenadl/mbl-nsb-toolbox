function [idx,ion,iof] = dwgetspike(yy,sig,dir)
% DWGETSPIKE   Simple spike detection for imaq_slowwave
%   idx = DWGETPSIKE(yy,sig) performs simple spike detection:
%   (1) find peaks yy>2*sig.
%   (2) drop minor peaks within 50 samples of major peaks.
%   (3) repeat for peaks yy<-2*sig.
%   DWGETSPIKE(yy,sig,dir) only finds +ve spikes if DIR>0 or only -ve
%   spikes if DIR<0.
%   [idx, ion, iof] = DWGETSPIKE(...) also returns entering and exiting
%   indices for each spike.
%   If SIG is a tuple [FAC BIN PERC] then the threshold is determined
%   automatically: the data is split into bins of BIN samples (default: 200
%   if BIN is given as NaN), the rms in each bin is determined, the bins
%   are sorted and the PERC-th percentile is taken (default PERC=40). Then,
%   spikes are detected at FAC x this value (default: FAC=2, which picks
%   a lot of junk spikes but is useful for subsequent sorting).
%   If SIG is a tuple [FAC BIN PERC MAXDT], then the kill interval is set
%   to MAXDT samples rather than 50.

if nargin<3
  dir=0;
end

if length(sig)==4
    maxdt=sig(4);
    sig=sig(1:3);
else
    maxdt=5*10;
end

if length(sig)==3
  N=length(yy);
  if isnan(sig(1))
    sig(1) = 1;
  end
  if isnan(sig(2))
    sig(2) = 200;
  end
  if isnan(sig(3))
    sig(3) = 40;
  end
  sig(2)=ceil(sig(2));
  K=floor(N/sig(2));
  rms = sort(std(reshape(yy(1:sig(2)*K),[sig(2) K])));
  sig = sig(1) * rms(ceil(K*sig(3)/100)) / 2;
end

%maxdt = fs*5; % 5 ms;

if dir>=0
  [ion,iof] = schmitt(yy,2*sig,0); K=length(ion);
  hei=zeros(K,1); ipk=zeros(K,1);
  for k=1:K
    [hei(k),ipk(k)] = max(yy(ion(k):iof(k)));
  end
  ipk(:)=ipk(:)+ion(:)-1;
  for k=1:K-1
    if hei(k)<hei(k+1) 
      if ipk(k+1)-ipk(k)<maxdt
	ipk(k)=0;
      end
    end
  end
  for k=2:K
    if hei(k)<hei(k-1) 
      if ipk(k)-ipk(k-1)<maxdt
	ipk(k)=0;
      end
    end
  end
  idx1=ipk(ipk>0);
  ion1=ion(ipk>0);
  iof1=iof(ipk>0);
else
  idx1=[];
  ion1=[];
  iof1=[];
end

if dir<=0
  [ion,iof] = schmitt(-yy,2*sig,0); K=length(ion);
  hei=zeros(K,1); ipk=zeros(K,1);
  for k=1:K
    [hei(k),ipk(k)] = min(yy(ion(k):iof(k)));
  end
  ipk(:)=ipk(:)+ion(:)-1;
  for k=1:K-1
    if hei(k)>hei(k+1)
      if ipk(k+1)-ipk(k)<maxdt
	ipk(k)=0;
      end
    end
  end
  for k=2:K
    if hei(k)>hei(k-1) 
      if ipk(k)-ipk(k-1)<maxdt
	ipk(k)=0;
      end
    end
  end
  idx2=ipk(ipk>0);
  ion2=ion(ipk>0);
  iof2=iof(ipk>0);
else
  idx2=[];
  ion2=[];
  iof2=[];
end

idx=[idx1(:); idx2(:)];
if nargout>=2
  ion=[ion1(:); ion2(:)];
  iof=[iof1(:); iof2(:)];
else
  clear ion iof
end
