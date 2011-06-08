% NERVEEXAMPLE - Example of the use of the functions for nerve data


% Load the data and find spikes:
ch=8;                                   % Select channel to investigate
[dat,tms] = loadephys('conoextra.daq'); % Load the file
spk = detectspike(dat(:,ch), tms);        % Detect the spikes

% Visualize intermediate results:
figure(1); clf                          % Create a clean figure
plot(tms,dat(:,ch));                    % Plot the raw data
hold on
plot(spk.tms,spk.amp,'.');              % Overlay the detected spikes
xlabel 'Time'
ylabel 'V_{electrode}'

% Manual intervention to select real spikes:
gdspk = selectspike(spk);

% Visualize those results
plot(gdspk.tms,gdspk.amp,'r.');         % Overlay over older graph

save goodspikes.mat gdspk


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load goodspikes.mat
[fr,tt] = instantfr(gdspk.tms);
figure(2); clf
plot(tt,1./fr);
xlabel 'Time (s)'
ylabel 'ISI (s)'
hold on
plot(gdspk.tms,gdspk.amp * max(1./fr) / max(gdspk.amp) / 2,'k.');

brst = burstinfo(gdspk.tms, 2.0, 151);
