function makeGammaTable_dotsX_remote(pathname, axs)
% testGammaTable_dotsX_remote
% 
% NOTE: THIS CREATES A GAMMA TABLE FILE TO BE USED ON THE REMOTE MACHINE
%   RUNNING DOTSX.
%   IT IS CALLED, BY DEFAULT, "Gamma_remote.mat"
%   YOU NEED TO MOVE IT TO THE OTHER MACHINE, RENAME IT APPROPRIATELY,
%   AND PUT IT IN THE PATH
%
% This script expects the optiCAL device to be placed directly over the
% center of the monitor to be tested
%
% See below for hints on using the optiCAL device
%
% Arguments:
%   pathname ... not empty to create gamma (use './' for current dir)
%   axs      ... if given, plotz of measured luminance values + resulting gamma table
%
% created 9/30/13 by jig

% other stuff
sampleInterval         = 0.1; % interval between luminance measurements, in sec
numValues              = 256;
maxV                   = numValues-1;
nominalLuminanceValues = 0:maxV;
values                 = nans(numValues, 1);

% go for it. make my day. are you feeling lucky, punk?
try
    
    rInit('remote');
    rAdd('dXtarget', 1, 'visible', true, 'diameter', 10);

    % set up the optiCAL device to start taking measurements
    % --> Use 'ls /dev/tty.*' to find device name
    % --> Use "instrfind" to find open serial objects
    % --> Returns in units of cd/m^2
    devName = '/dev/tty.USA19H141P1.1';
    opt = opticalSerial(devName);
    
    % loop through the luminances
    for ii = 1:numValues
        
        % show target
        rSet('dXtarget', 1, 'color', nominalLuminanceValues(ii)./(numValues-1).*[255 255 255]);
        rGraphicsDraw;
        
        % get luminance reading
        opt.getLuminance(1, sampleInterval);
        
        values(ii) = opt.values(end);
    end
    
catch
    
    % close the OpenGL drawing window
    rDone(1);
    
    % close the optiCAL device
    opt.close();
    
    % show error
    rethrow(lasterror)
end    

% close the optiCAL device
opt.close();

% close the OpenGL drawing window
rDone(1);

% make the gamma table
maxLum     = max(values);
scaledLum  = linspace(0, maxLum, numValues);
gammaTable = zeros(3, numValues);
for ii = 2:numValues
    gammaTable(:,ii) = nominalLuminanceValues( ...
        find(values>=scaledLum(ii),1,'first'))./maxV.*[1 1 1];
end
    
% conditionally save dotsX gamma table for remote machine
if nargin > 0 && ~isempty(pathname)
    gammaNameX = fullfile(pathname, 'Gamma_remote.mat');
    gamma8bit  = gammaTable';
    save(gammaNameX, 'gamma8bit');
end

if nargin > 1 && ~isempty(axs)
    
    % PLOT:
    % black = nominal values
    % red = actual lumanance values
    % green = gamma table
    % blue = "as if" using gamma table
    
    cla reset; hold on;
    plot([0 maxV], [0 1], 'k-');
    plot(values./max(values), 'r-');
    plot(gammaTable(1,:), 'g-');
    asif = values(round(gammaTable(1,:).*maxV)+1);
    plot(asif./max(asif), 'b-');
    title(sprintf('Max = %.2f', max(values)))
    axis([0 maxV 0 1]);    
end
