function makeGammaTable(screenIndex, pathname, gammaType, axs)
% makeGammaTable
% 
% Script to use the Cambridge Systems optiCAL device with snow dots to
% create a gamma table
%
% This script expects the optiCAL device to be placed directly over the
% center of the monitor to be calibrated
%
% See below for hints on using the optiCAL device
%
% Results in a gamma file being placed in the directory specified by 
%   GAMMA_PATHNAME. See dotsTheScreen.getHostGammaTableFilename 
%   for naming conventions for this file.
%
% Arguments:
%   screenIndex  ... 0=small rectangle on main screen; 1=main screen; 2=secondary
%   pathname     ... if given, path to save gammaTable file
%   gammaType    ... 0:test only; 1:make standard; 2:make for dotsX; 
%   axs          ... if given, plotz of measured luminance values + resulting gamma table
%
% created 6/14/13 by jig

if nargin < 1 || isempty(screenIndex)
    screenIndex = 1;
end

if nargin < 2 || isempty(pathname)
    pathname = './';
elseif strcmp(pathname, 'jigold')
    pathname = '/Users/jigold/GoldWorks/Mirror_jigold/Matlab/Configuration/';
end

if nargin < 3 || isempty(gammaType)
    gammaType = 1;
end

if nargin < 4
    axs = [];
elseif axs == 2
    figure;
    axs(1) = subplot(2,1,1);
    axs(2) = subplot(2,1,2);
end

% other stuff
sampleInterval         = 0.1; % interval between luminance measurements, in sec
numValues              = 256;
maxV                   = numValues-1;
nominalLuminanceValues = 0:maxV;
values                 = nans(numValues, 1);

% use a nominal gamma table
if gammaType>0
    gammaName  = fullfile(pathname, dotsTheScreen.getHostGammaTableFilename());
    gammaTable = repmat(nominalLuminanceValues, 3, 1)./maxV;
    save(gammaName, 'gammaTable');
end

% go for it. make my day. are you feeling lucky, punk?
try
    
    % initialize snow dots
    dotsTheScreen.reset();
    s = dotsTheScreen.theObject;
    s.displayIndex = screenIndex;
    dotsTheScreen.openWindow();
    
    % make target on the center of the screen
    t = dotsDrawableTargets();
    t.xCenter = 0;
    t.yCenter = 0;
    t.width   = 10;
    t.height  = 10;
    
    % set up the optiCAL device to start taking measurements
    % --> Use 'ls /dev/tty.*' to find device name
    % --> Use "instrfind" to find open serial objects
    % --> Returns in units of cd/m^2
    devName = '/dev/tty.USA19H64P1.1';
    opt = opticalSerial(devName);
    
    % loop through the luminances
    for ii = 1:numValues
        
        % show target
        t.colors = nominalLuminanceValues(ii)./(numValues-1).*[1 1 1];
        dotsDrawable.drawFrame({t});
        
        % get luminance reading
        opt.getLuminance(1, sampleInterval);
        
        values(ii) = opt.values(end);
    end
    
catch
    
    % close the OpenGL drawing window
    dotsTheScreen.closeWindow();
    
    % close the optiCAL device
    opt.close();
    
    % show error
    rethrow(lasterror)
end    

% close the optiCAL device
opt.close();

% close the OpenGL drawing window
dotsTheScreen.closeWindow();

% make the gamma table
if gammaType > 0
    maxLum     = max(values);
    scaledLum  = linspace(0, maxLum, numValues);
    gammaTable = zeros(3, numValues);
    for ii = 2:numValues
        gammaTable(:,ii) = nominalLuminanceValues( ...
            find(values>=scaledLum(ii),1,'first'))./maxV.*[1 1 1];
    end
    
    % save to file
    save(gammaName, 'gammaTable');
    
    % maybe save dotsX gamma table
    if gammaType == 2
        [s,w] = unix('hostname');
        gammaNameX = fullfile(pathname, ['Gamma_', w(1:find(w == '.',1)), 'mat']);
        gamma8bit  = gammaTable';
        save(gammaNameX, 'gamma8bit');
    end
end

if nargin > 3 && ~isempty(axs)
    
    % get gamma-corrected values
    axes(axs(1));
    cla reset; hold on;
    plot([0 maxV], [0 1], 'k-');
    plot(values./max(values), 'r-');
    if gammaType > 0
        plot(gammaTable(1,:), 'g-');
        asif = values(round(gammaTable(1,:).*maxV)+1);
        plot(asif./max(asif), 'b-');
    end
    title(sprintf('Max = %.2f', max(values)))
    axis([0 maxV 0 1]);
    
    if length(axs) > 1
        makeGammaTable(screenIndex, [], 0, axs(2));
    end
end
