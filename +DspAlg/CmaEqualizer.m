function [yy h mse] = CmaEqualizer(xx, h, taps, mu, R, sps, err_id)
%CMAEQUALIZER Channel equalization filter using CMA algorithm
%
%   According to the "Adaptive filting theory", at the moment of
%   convergence, the "error signal" should be orthogonal to the filter
%   input, i.e., (err)*conj(x) => 0, which is proportional to the increment
%   of the filter coefficients.
%
%   [1] D. N. Godard, "Self-Recovering Equalization and Carrier Tracking in
%   Two-Dimensional Data Communication Systems," IEEE Trans. Commun., vol.
%   COM-28, no. 11, Nov. 1980
%
%   Example:
%   
%   See also: PolarizationDemux,CmaEqualizer2

%   Copyright2010 WANGDAWEI 16/3/2010

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 7,  err_id = 1; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = length(xx);       % Length of eXtended X = length(X) + taps -1
ntap = taps;          % Number of Taps
L = N-ntap+1;         % Length of outputs
yy = zeros( L, 1 );   % Output vector initialized to zero
mse = zeros(1, L);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ktime = 1:L
    nindex = ktime : ktime+ntap-1;  % time index for inputs
    X1 = xx( nindex, : ) .* h;
    yy( ktime ) =  sum( X1 );       % Calculating outputs
    if (sps==1 || mod(ktime-1,sps)==0)
        incr = mu.*errorfuncma( yy(ktime), R, err_id).*conj( xx(nindex,:) );
        h = h + incr;
    end
    if err_id == 1
        mse(ktime) = (abs(yy(ktime)).^2 - R).^2;
    else
        mse(ktime) = (real(yy(ktime)).^2+imag(yy(ktime)).^2-2*R).^2;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Err = errorfuncma( X, R, IDX)
switch IDX
    case 1   %%% Classical CMA
        Err = -X.*(abs(X).^2-R);
    case 2   %%% Modified CMA
        Err = -1.*complex(real(X).*(real(X).^2-R),imag(X).*(imag(X).^2-R));
    case 3   %%% Cascaded multi-modulus algorithm
        A1 = 0.5*(R(1)+R(2));
        A2 = 0.5*(R(3)-R(1));
        A3 = 0.5*(R(3)-R(2));
        e1 = abs(X)-A1; e2 = abs(e1)-A2; e3 = abs(e2)-A3;
        Err = -sign(X).*e3;
    case 4   %%% Radius directed
        Err = X.*min(R -abs(X).^2);
    case 5   %%% half-constellation MCMA
        window = windecision(real(X),2/3) || windecision(imag(X),2/3);
        Err = -1.*window.*complex(real(X).*(real(X).^2-R(1)),imag(X).*(imag(X).^2-R(2)));
    case 6   %%% Modified radius directed
        Err = complex(real(X).*min(R-real(X).^2),imag(X).*min(R-imag(X).^2));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = windecision(x, D)
y = 0.5*(1+sign(x.^2-D.^2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%