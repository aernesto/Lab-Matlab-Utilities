function ret_ = verify(a, channels)
% function ret_ = verify(a, channels)
%
% verify method for class analog
%
% verifies whether the given analog channels
%   are in the "keep_sigs" list

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania
%
% history:
% written 11/23/04 by jig

% default
if nargin < 2
    ret_ = false;
    
elseif isempty(a.keep_sigs)
    ret_ = false(size(channels));
    
elseif strcmp(a.keep_sigs, 'all')
    ret_ = true(size(channels));
    
elseif ischar(channels)

    if any(strcmp(channels, a.names))
        ret_ = true;
    elseif strcmp(channels(1:2), 'AD')
        ret_ = ismember(sscanf(channels, 'AD%f'), a.keep_sigs);
    else
        ret_ = false;
    end

elseif iscell(channels)
    ret_ = true(size(channels));
    for ii = 1:length(channels)
        ret_(ii) = verify(a, channels{ii});
    end
end
