function [yout,mse,deth,h1] = lms_sng_eq( xin,mn,sps,mu,ntaps,iter,h1)
%lms_sng_eq LMS single polarization equalization
%   
%   Copyright2011 WANGDAWEI $10/9/2012$ 

x = DspAlg.Normalize(xin, mn);

x = x / (sqrt(mn)-1);

% make sure the tap number is odd
ntaps = ntaps + ~mod(ntaps,2);

% taps initialization
if nargin < 7
    halfnt = floor(ntaps/2);
    h1 = zeros(ntaps,1);
    h1(halfnt+1) = 1;
end

if length(h1) ~= ntaps
    error('filter taps length error');
end

cstl = constellation(mn)/(sqrt(mn)-1);
extendx = [ x(end-halfnt+1:end,:); x; x(1:halfnt,:)];

for ii = 1:iter
    [xx,mse,deth] = LMS_FILTER_sng(extendx,h1,ntaps,mu,cstl,sps);
    %%[xx,mse,deth] = MCMA_FILTER_sng(extendx,h1,ntaps,mu,radius,sps,errid);
end

% format the output
yout    = xx(1:sps:end,:);
mse     = mse(1:sps:end);
deth    = deth(1:sps:end);