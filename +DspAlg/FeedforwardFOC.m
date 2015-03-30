function [y,df] = FeedforwardFOC(x,symrate,fok)
%FEEDFORWARDFOC frequency offset estimation routine using bell-lab style
%
%   Example
%   
%   See also 
%
%   copyright2010 wangdawei 16/3/2010

N = length(x);

% if the frequency offset is given
if nargin == 3
    delta_phi = fok/symrate*2*pi;
    phioff = (1:N) * delta_phi;
    y = x.*(exp(1j*phioff.')*ones(1,size(x,2)));
    df = fok;
    return
end

% estimate the frquency offset
data2 = x(2:end,:).^4;
data1 = x(1:end-1,:).^4;
data  = data2.*conj(data1);
angle_acq = angle(sum(data))/4;
delta_phi = -mean(angle_acq);
phioff = (1:N) * delta_phi;

% compensate
y = x.*(exp(1j*phioff(:))*ones(1,size(x,2)));
df = delta_phi*symrate/(2*pi);
