% This is a script that contains all the example code in Chapter 5.


[vlt,tms] = loadephys('intraextra.xml');

whos

Vint_mV = vlt(:,2);
Iint_nA = vlt(:,4)/10;
Vext_uV = vlt(:,6)/10;

figure(1); clf
subplot(3,1,1); plot(tms, Vint_mV, 'b');
subplot(3,1,2); plot(tms, Iint_nA, 'r');
subplot(3,1,3); plot(tms, Vext_uV, 'k');
linkaxes(get(gcf,'children'),'x');

figure(2); clf; hold on;
plot(tms, Vint_mV, 'r');
plot(tms, Vext_uV/3+20, 'k');
axis([.95 1.5 -100 60]);

intspk = selspktrace(Vint_mV,tms);

figure(1); clf; hold on
N = length(intspk.tms);
clr = jet(N);
for k=1:N
    idx=find(tms==intspk.tms(k));
    if idx>200 & idx<length(tms)-200
        plot(tms(idx-200:idx+200)-tms(idx), ...
            Vext_uV(idx-200:idx+200),'color',clr(k,:));
    end
end

[avg,dt,indiv] = trigavg(Vext_uV,tms, intspk.tms);
subplot(2,1,1); plot(dt,avg);
subplot(2,1,2); plot(dt,indiv);

[mx,idx] = min(avg);
avgdelay = dt(idx)

[mxx,dtt] = trigavgmax(-indiv,dt);
failures = find(trigavgfail(mxx));
