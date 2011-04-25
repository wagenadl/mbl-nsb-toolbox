function [b,a]=butterhigh1(f)
% [b,a] = BUTTERHIGH1(wn) creates a first order high-pass Butterworth filter
% with cutoff at WN. (WN=1 corresponds to the sample frequency, not half!)
% 
% Filter coefficients lifted from http://www.apicsllc.com/apics/Sr_3/Sr_3.htm
% by Brian T. Boulter

c = cot(f*pi);

n0=c; 
n1=-c;
d0=c+1;
d1=-c+1;

a=[1 d1./d0];
b=[n0./d0 n1./d0];
