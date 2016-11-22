% longTimingTest
%

%% flash for one second
SCREEN_INDEX   = 2;  % 0=small rectangle on main screen; 1=main screen; 2=secondary
NUM_REPS       = 10;
FRAMES_PER_REP = 30;
SCREEN_DELAY   = 0.05; % sec

%% setup screen
dotsTheScreen.reset();
s = dotsTheScreen.theObject;
s.displayIndex = SCREEN_INDEX;
dotsTheScreen.openWindow();
frameInterval = 1./s.windowFrameRate;

% make target on the center of the screen ... flash a few times
t = dotsDrawableTargets();
t.xCenter = 0;
t.yCenter = 0;
t.width   = 10;
t.height  = 10;
for ii = 1:10
    t.colors = ones(1,3).*mod(ii,2);
    timing   = dotsDrawable.drawFrame({t});
end
    
%% configure device
aIn = AInScan1208FS();
aIn.channels  = 0; % differential channel 0 is inputs 0 & 1
aIn.gains     = 7; % 20x = +/-1V; see MCCFormatReport
aIn.frequency = 2000;
aIn.nSamples  = ceil(aIn.frequency .* (SCREEN_DELAY*2 + FRAMES_PER_REP*frameInterval));

timingData = nans(NUM_REPS, aIn.nSamples);
for nn = 1:NUM_REPS
    configTime = aIn.prepareToScan();
    startTime  = aIn.startScan(); % host CPU time, when start ack'd by USB device
    for ii = 1:FRAMES_PER_REP
        t.colors = ones(1,3).*mod(ii,2);
        timing   = dotsDrawable.drawFrame({t});
    end
    pause(SCREEN_DELAY*2);
    mexHID('check'); % probably not necessary...
            
    % cleanup
    stopTime = aIn.stopScan();
    [chans, volts, times, uints] = aIn.getScanWaveform();
    timingData(nn,1:length(volts)) = volts;
end

% clean up
dotsTheScreen.closeWindow();
aIn.close();

%% Plot raw data
cla reset; hold on;
plot(timingData')
