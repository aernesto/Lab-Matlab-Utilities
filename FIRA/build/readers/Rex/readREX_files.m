function error_ = readREX_files(filename)
%function error_ = readREX_files(filename)
%
% Calls readREX_eFile and readREX_aFile to open the 'E' and
%  'A' files generated by REX, then puts the data into the global
%  FIRA data structure, as follows:
%
%    FIRA.header.filename ... {Afilename; Efilename}
%    FIRA.header.filetype ... 'rex'
%    FIRA.header.paradigm ... paradigm number, read from ecodes
%
%    FIRA.raw.ecodes      ... array of <timestamp> <ecode>
%    FIRA.raw.spikes      ... spike data
%    FIRA.raw.afunc       ... function to parse analog data
%    FIRA.raw.aparams     ... parameters needed by afunc
%    FIRA.raw.adata       ... the analog data
%    FIRA.raw.matCs       ... array of matlab commands
%    FIRA.raw.matAs       ... array of matlab arguments
%    FIRA.raw.matAi       ... index to parse matAs
%    FIRA.raw.dios        ... array of dio commands
%
% Arguments:
%   filename  ... full path and base name (typically
%       without 'A' or 'E' suffix, but it can handle it with
%       either or without)
%
% Returns:
%   error_ flag
%   also fills appropriate fields of the global FIRA
%

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania
%
% history:
%   modified 10/14/04 by jig
%   created 1/24/02 by jig
%

global FIRA

% check args
error_ = 1;
if nargin < 1 || isempty(filename) || isempty(FIRA)
    return
end

% try to find the files
if filename(end) == 'A'
    afile = filename;
    efile = [filename(1:end-1) 'E'];
elseif filename(end) == 'E'
    afile = [filename(1:end-1) 'A'];
    efile = filename;
else
    afile = [filename 'A'];
    efile = [filename 'E'];
end

% default "file_type", if readREX_AFile doesn't work
ft = [];

%% FIRST OPEN AFILE, if necessary
%%  we do this first because the analog file contains "magic numbers"
%%  that we can use to determine byte ordering
if isfield(FIRA, 'analog')

    [ainfo, FIRA.raw.analog.data, ft] = readREX_aFile(afile);

    % if we got analog data, save header info
    if ~isempty(ainfo) && ~isempty(FIRA.raw.analog.data)
        
        % verify the actual channels to keep
        ks = unique(ainfo.store_order(verify(FIRA.spm.analog, ainfo.store_order)));
                
        if isempty(ks)
            disp(sprintf('readRex_files: desired sigs not found in file <%s>', afile))
        else

            % 1-based store order is only parameter (other than
            % keep_sigs) needed by parseREX_aData
            FIRA.raw.analog.params = struct( ...
                'keep_sigs',   ks, ...
                'store_order', ainfo.store_order);

            % save the parse function
            FIRA.raw.analog.func = @parseREX_aData;

            % save the name, store rate in FIRA.analog
            % remember FIRA.raw.keep_sigs is now sorted, 0-based, so just
            % add 1 for indices
            FIRA.analog.name       = cellstr([ainfo.title(:, ks)']);
            FIRA.analog.store_rate = ainfo.store_rate(ks)';
        end
    end
end

% SECOND OPEN EFILE, ALWAYS
% if we got something in the Efile, fill in FIRA
codes = readREX_eFile(efile, ft);
if ~isempty(codes)
    
    % find the first trial
    scode = min(find(codes(:,2)==buildFIRA_get('trial', 'startcd')));
    if isempty(scode)
        error(sprintf('file <%s> has no trials', efile))
    end
    
    % fill in the FIRA header
    FIRA.header.filename = {afile, efile};
    FIRA.header.filetype = 'rex';

    % now for the tricky part... we determine whether the file
    % is "old style" or "new style":
    %   Old style means that it includes just codes & spikes; 
    %     if this is true, the paradigm number is sent with an "init
    %     mask" of 8192 (2^13) -- that is, code = 8192 + pnum.
    %   New style means that it is using the new "ecode" format
    %     developed by jig & jd. In this case, we have codes,
    %     Matlab cmds, Matlab args, and dio commands. See
    %     rex/mns/ecode.c for details. Here the init mask = 20480.
    mask_ind = find(codes(1:scode,2)>8192);
    if length(mask_ind) == 1 && codes(mask_ind,2) < 20480
        FIRA.header.paradigm  = codes(mask_ind(1),2) - 8192; % old style
    elseif isempty(mask_ind) || length(mask_ind) > 1
        FIRA.header.paradigm = -1; % new style
    else
        FIRA.header.paradigm = codes(mask_ind,2) - 20480;
    end
    
    % make parseCU_rawCodes do the work of parsing ecodes, etc
    % from the list of codes (and timestamps)
    parseEC_rawCodes(codes);
    
    error_ = 0;
end
