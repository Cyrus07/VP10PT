function varargout = SignalPrenormalize( varargin )
%SIGNALPRENORMALIZE Summary of this function goes here
%   Detailed explanation goes here

for k = 1:length(varargin)
    
    % remove the dc componant
    a = varargin{k}(:) - mean(varargin{k});
    
    % unit the mean power
    b = a / sqrt(mean(a.^2));
    
    % remove the non-numerical
    b(isnan(b)) = 0;
    
    varargout{k} = b;
end

