function ff = trigavgfail(mxx)
% TRIGAVGFAIL - Identifies cases of propagation failure
%    ff = TRIGAVGFAIL(mxx) determines which of the values in MXX are
%    less than the average and returns a corresponding array of logical 
%    zeros and ones. This is meant to be used in conjunction with
%    TRIGAVGMAX, which see.

av = mean(mxx);
thr = 0.5;
if av<0
  ff = mxx>av*thr;
else
  ff = mxx<av*thr;
end
