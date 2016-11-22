%% A few points to remember:
%
% - macs on intel are LITTLE ENDIAN
% - use 'ls /dev/tty.*' to find device name

%% use opticalSerial class from Cambridge
%
devName = '/dev/tty.USA19H64P1.1';
opt = opticalSerial(devName);
opt.getLuminance(100, .5)


%% Open the connection using 
%   KEYSPAN USB-to-Serial Converter: USA-19HS
%
%   OptiCAL communicates via a standard RS-232 serial
%   port, using the protocol: 9600 baud rate, no parity, and
%   1 stop bit
optiCAL_port = serial('/dev/tty.USA19H64P1.1', 'BaudRate', 9600, ...
    'DataBits', 8, 'StopBits', 1, 'Timeout', 5);

% some useful vals
ACK = 6;

% path(path, '/Applications/MATLAB_R2010b.app/toolbox/shared/instrument');
% a.FlowControl = '';
% a.Terminator = '';
% a.RequestToSend = 'off';
% a.ByteOrder = 'littleEndian'; %'bigEndian'; % 'littleEndian'
 
%% open the port
fopen(optiCAL_port)

%% Calibrate
%
% send command and wait a few seconds
%   for ACK return value
fprintf(optiCAL_port, '%s', 'C');
tic
ret = 0;
while toc < 5 && ret ~= ACK
    ret = fread(optiCAL_port, 1, 'uint8');
end
if ret == ACK
    disp(sprintf('Calibration successful in %.2s', toc))
else
    disp('Calibration NOT successful')
end

%% Read info from device
% product type (2 bytes)
out = zeros(2,2,'uint8');
for bb = 1:2
    fprintf(optiCAL_port, '%s', char(128+bb-1));
    out(:,bb) = fread(optiCAL_port, 2, 'uint8');
end
product_type = typecast(out(1,:), 'uint16');

% serial number (4 bytes)
out = zeros(2,4,'uint8');
for bb = 1:4
    fprintf(optiCAL_port, '%s', char(128+bb+1));
    out(:,bb) = fread(optiCAL_port, 2, 'uint8');
end
optical_serial_number = typecast(out(1,:), 'uint32');

% firmware version number*100 (2 bytes)
out = zeros(2,2,'uint8');
for bb = 1:2
    fprintf(optiCAL_port, '%s', char(128+bb+5));
    out(:,bb) = fread(optiCAL_port, 2, 'uint8');
end
firmware_version = double(typecast(out(1,:), 'uint16'))./100.;

% VREF = Reference voltage (4 bytes)
out = zeros(2,4,'uint8');
for bb = 1:4
    fprintf(optiCAL_port, '%s', char(128+bb+15));
    out(:,bb) = fread(optiCAL_port, 2, 'uint8');
end
VREF = typecast(out(1,:), 'uint32');

% ZCOUNT = zero error (4 bytes)
out = zeros(2,4,'uint8');
for bb = 1:4
    fprintf(optiCAL_port, '%s', char(128+bb+31));
    out(:,bb) = fread(optiCAL_port, 2, 'uint8');
end
ZCOUNT = typecast(out(1,:), 'uint32');

% RFEED = feedback resistor (4 bytes)
out = zeros(2,4,'uint8');
for bb = 1:4
    fprintf(optiCAL_port, '%s', char(128+bb+47));
    out(:,bb) = fread(optiCAL_port, 2, 'uint8');
end
RFEED = typecast(out(1,:), 'uint32');

% RGAIN = voltage gain resistor (4 bytes)
out = zeros(2,4,'uint8');
for bb = 1:4
    fprintf(optiCAL_port, '%s', char(128+bb+63));
    out(:,bb) = fread(optiCAL_port, 2, 'uint8');
end
RGAIN = typecast(out(1,:), 'uint32');

% probe serial number (ASCII 16 characters)
out = zeros(2,16,'uint8');
for bb = 1:16
    fprintf(optiCAL_port, '%s', char(128+bb+79));
    out(:,bb) = fread(optiCAL_port, 2, 'uint8');
end
probe_serial_number = char(out(1,:));

% KCAL = probe calibration (4 bytes)
out = zeros(2,4,'uint8');
for bb = 1:4
    fprintf(optiCAL_port, '%s', char(128+bb+95));
    out(:,bb) = fread(optiCAL_port, 2, 'uint8');
end
KCAL = typecast(out(1,:), 'uint32');

disp(sprintf('Product type     : %d', product_type))
disp(sprintf('Optical S/N      : %d', optical_serial_number))
disp(sprintf('Firmware version : %.2f', firmware_version))
disp(sprintf('V_ref            : %d', VREF))
disp(sprintf('Z_count          : %d', ZCOUNT))
disp(sprintf('R_feed           : %d', RFEED))
disp(sprintf('R_gain           : %d', RGAIN))
disp(sprintf('Probe S/N        : <%s>', probe_serial_number))
disp(sprintf('K_cal            : %d', KCAL))


%% Put into current mode
fprintf(optiCAL_port, '%s', 'I');
if fread(optiCAL_port, 1, 'uint8') == ACK
    disp('In current mode');
end

%% read data
% useful values from stored parameters
denom  = double(KCAL)*double(RFEED)*(1e-15);
vscale = double(VREF)*(1e-6);

for ii = 1:15    
    fprintf(optiCAL_port, '%s', 'L');
    out    = fread(optiCAL_port, 4, 'uint8');
    ADC    = typecast([out(1:3)' uint8(0)], 'uint32');
    ADCC   = double(ADC - ZCOUNT - 524288);
    LUM    = ((ADCC/524288.)*vscale)/denom;
    disp(LUM)
    pause(0.5)
end

%% Close the port
fclose(optiCAL_port);
delete(optiCAL_port)
clear optiCAL_port






%% JUNK
% % SerialComm knows how to:
% %   SerialComm( 'open', PORT, CONFIG);
% %   str = SerialComm( 'readl', PORT, EOL);
% %   str = SerialComm( 'read', PORT, N);
% %   SerialComm( 'write', PORT, command);
% %   SerialComm( 'purge', PORT);
% %   SerialComm( 'hshake', PORT, HSHAKE);
% %   SerialComm( 'break', PORT);
% %   SerialComm( 'close', PORT);
% %   SerialComm( 'status', PORT);
% 
% % open communication with OptiCAL
% CONFIG = '9600,n,8,1'; % '19200,n,8,1';
% PORT = 2;
% comm('open', PORT, CONFIG);
% 
% % maybe purge any read/writes
% comm('purge', PORT);
% 
% % calibrate OptiCAL, once per session
% comm('write', PORT', 'C')
% ret = comm('read', PORT, 1)
% 
% for pp = 1:7
%     disp(pp)
%     comm('open', pp, CONFIG);
%     pause(.5);
%     comm('purge', pp);
%     pause(.5);
%     comm( 'status', pp);
%     pause(.5);
%     comm('write', pp', 'C')
%     pause(4);
%     comm('read', pp, 1)
%     pause(.5);
%     comm( 'close', pp);
%     pause(.5);
% end
% 
% 
% EOL = sprintf('\n');
% ret = SerialComm('readl', PORT, EOL)
% 
% 
% 
% EOL = sprintf('\n');
% N = 10;
% HSHAKE = 's'; %'h' 's' 'n'
% 
% % Symbols to send out to the J17:
% BEGIN   = '!';
% END     = sprintf('\n');
% REPORT  = 'NEW';
% % the NEW command may take an argument, the number of samples to report at once.
% %   1-127 is number of samples
% %   128-255 is continuous sampling until another command
% num_at_once = 1;
% command = sprintf('%s%s %d%s',BEGIN,REPORT,num_at_once,END);
% 
% % allocate returns
% unit = cell(1, num_samples);
% data = nan*ones(1, num_samples);
% time = nan*ones(1, num_samples);
% 
% % reading takes a bit of time
% interval = .7;
% if ~leave_open && num_samples > 0
%     disp(sprintf('reading %d samples from J17 will take ~%.1fs', ...
%         num_samples, num_samples*interval));
% end
% 
% % start SerialComm with J17 on COM2 port
% if ~no_open
%     SerialComm('open', PORT, CONFIG);
% end
% 
% try
%     SerialComm( 'purge', PORT);
%     know = GetSecs;
%     returns = 0;
%     tries = 0;
%     while returns < num_samples && tries < 10*num_samples
% 
%         % trigger one report at a time from the J17
%         s = SerialComm('write', PORT, command);
