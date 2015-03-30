function y = Normalize(x, mn)
%NORMALIZE Normalize signal to its common form
%
% Example
%   
% See also 

% Copyright2011 WANGDAWEI 16/3/2011

% tmp = sqrt(mean(abs(x).^2));
tmp = mean(abs(x));

ncl = size(x,2);
if (ncl > 1)
    tmp = mean(tmp);
end

% get the scaling factor for common form
% scale_factor = sqrt(mean(abs(constellation(mn)).^2));
scale_factor = mean(abs(constellation(mn)));

% first normalize signal to UNIT average symbol energy
% then, multiply with scaling factor
y = x/tmp*scale_factor;