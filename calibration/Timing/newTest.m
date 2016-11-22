% testMonitorTiming
%
% play with timing using PMD-1208FS, Optoelectronics photodiode, a bottle
% of wine and a smile
%

%% flash for one second
SCREEN_INDEX  = 1;  % 0=small rectangle on main screen; 1=main screen; 2=secondary
NUM_REPS      = 2;
NUM_FRAMES    = 12;

dotsTheScreen.reset();
s = dotsTheScreen.theObject;
s.displayIndex = SCREEN_INDEX;
dotsTheScreen.openWindow();

% make target on the center of the screen ... flash a few times
t = dotsDrawableTargets();
t.xCenter = 0;
t.yCenter = 0;
t.width   = 10;
t.height  = 10;
t.colors  = ones(1,3);

%% configure device
aIn = AInScan1208FS();
aIn.channels  = 0; % differential channel 0 is inputs 0 & 1
aIn.gains     = 7; % 20x = +/-1V; see MCCFormatReport
aIn.frequency = 2000;
aIn.nSamples  = aIn.frequency;

frameTiming   = nans(NUM_FRAMES, NUM_REPS, 4);
OSOdata       = nans(aIn.nSamples, 2, NUM_FRAMES, NUM_REPS);
for rr = 1:NUM_REPS
    for ii = 1:NUM_FRAMES
        
        configTime = aIn.prepareToScan();
        startTime  = aIn.startScan(); % host CPU time, when start ack'd by USB device
        s.resetFlushGauge();
        
        pause(0.001.*(7+ii));
        timing = dotsDrawable.drawFrame({t});
        frameTiming(ii,rr,1) = timing.onsetTime;
        frameTiming(ii,rr,3) = timing.onsetFrame;
        frameTiming(ii,rr,4) = timing.swapTime;
        s.blank();
        pause(0.05);
        
        % find crossing time
        stopTime = aIn.stopScan();
        [chans, volts, times, uints] = aIn.getScanWaveform();
        frameTiming(ii,rr,2) = times(find(volts>=mean(volts(1:10)) + 0.5*(max(volts)-mean(volts(1:10))),1));
        sz = length(volts);
        OSOdata(1:sz,:,ii,rr) = [times' volts'];
        disp([rr ii])
    end
end

% clean up
dotsTheScreen.closeWindow();
aIn.close();

cla reset; hold on;
plot(7+(1:NUM_FRAMES), 1000*(frameTiming(:,:,2)-frameTiming(:,:,1)), 'k.')
plot(7+(1:NUM_FRAMES), 1000.*frameTiming(:,:,3).*s.flushGauge.framePeriod, 'r.')
plot(7+(1:NUM_FRAMES), frameTiming(:,:,4).*10, 'b.')

figure
for ii = 1:NUM_FRAMES
    subplot(NUM_FRAMES,1,ii); cla reset; hold on
    for rr = 1:NUM_REPS
        plot(OSOdata(:,1,ii,rr)-frameTiming(ii,rr,1), OSOdata(:,2,ii,rr), 'k-');
        plot((frameTiming(ii,rr,2)-frameTiming(ii,rr,1)).*[1 1], [0 .4], 'r-');
    end    
    axis([-0.05 0.05 0.05 0.35])
end







% wait a short, random time
    %pause(rand./5);
    pause(0.001);
    
    % flash on/off 5 times
    for ii = 1:NUM_FRAMES
        pause(pauses(ii).*0.001);
        t.colors = ones(1,3).*mod(ii,2);
        timing = dotsDrawable.drawFrame({t});
        frameTiming(ii,rr) = timing.onsetTime;
    end
    s.blank();
    pause(0.02);

    % cleanup
    stopTime = aIn.stopScan();
    [chans, volts, times, uints] = aIn.getScanWaveform();
    sz = length(volts);
    OSOdata(1:sz,:,rr) = [times' volts'];
end

% clean up
dotsTheScreen.closeWindow();
aIn.close();


%% Plot raw data
figure
cla reset; hold on
for rr = 1:NUM_REPS
    plot(OSOdata(:,1,rr)-frameTiming(1,rr), OSOdata(:,2,rr), 'k-');
    
    for ii = 1:2:NUM_FRAMES
        plot((frameTiming(ii,rr)-frameTiming(1,rr)).*[1 1], [0 1], 'g-');
    end
    for ii = 2:2:NUM_FRAMES
        plot((frameTiming(ii,rr)-frameTiming(1,rr)).*[1 1], [0 1], 'r-');
    end
    %axis([-.1 0.2 0.1 0.4]);
end



