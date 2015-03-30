function [y phi] = FeedbackCPE(x,mn,mu,bs,initial,appML,iter)
%FEEDFACKCPE Decision-directed feefback carrier phase recovery routine
%
% Neglect the amplitude noise, data received rx = A*exp(j*phi1) and its
% decisiion dx = A*exp(j*phi0). The error x err = rx*exp(-j*phierr)-dx
% = A*exp(j*phi0)*[exp(j(phi1-phi0-phierr))-1], where phierr is current
% estimated phase error and (phi1-phi0-phierr) would be the error of the
% estimated phase error. We take [rx*exp(-j*phierr)]*[conj(err)] =
% A^2*[1-exp(j*(phi1-phi0-phierr))], using imaginary part to approximate
% the error of phase error.
%
% Example
% 
% See also FeedforwardCPE

% Copyright2010 WANGDAWEI 16/3/2010

if nargin < 7
    iter = 1;
end
if nargin < 6
    appML = 0;
end
if nargin < 5
    initial = zeros(1,size(x,2));
end
if nargin < 4
    bs = 16;
end

if isempty(initial)
    initial = zeros(1,size(x,2));
end

x = DspAlg.Normalize(x,mn);
y = zeros(size(x));
N = length(x);
phi(1,:) = initial;

for kk = 1:N
    zz = x(kk,:) .* exp(-1j*phi(kk,:));
    y(kk,:) = zz;
    aa = DspAlg.slicer(zz,mn);
    err = zz - aa;
    phi(kk+1,:) = phi(kk,:) - mu*imag( zz.* conj(err) );
end

if appML
    b = zeros(size(y));
    h = zeros(size(y));
    for ii = 1:iter
        for pol = 1:size(y,2)
            b(:,pol) = DspAlg.slicer(y(:,pol),mn);
            h(:,pol) = smooth(y(:,pol).*conj(b(:,pol)),bs);
            y(:,pol) = y(:,pol).* exp(-1j*angle(h(:,pol)));
        end
    end
end


