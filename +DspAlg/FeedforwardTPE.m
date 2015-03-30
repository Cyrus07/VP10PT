

function [y,phEst] = FeedforwardTPE(signal,mn,sps,szBlock,bias,estMeth,intMeth,decFlag,norFlag, RectifyPolyCoff)
%FEEDFORWARDTPE Feedforward timing phase estimation and recovery. The input
%parameters are defined as follows:
%
%   szBlock: block size
%   estMeth: estimator method
%   intMeth: interpolation method
%   decFlag: decimate flag
%   norFlag: normalize flag
%
%   Example
%   
%   See also: FeedbackTPE

%   Copyright2012 wangdawei 16/6/2012
if nargin<10
    RectifyPolyCoff = [];
end
if nargin<9
    norFlag = 1;
end
if nargin<8
    decFlag = 1;
end
if nargin<7
    intMeth = 'linear';
end
if nargin<6
    estMeth = 'lee';
end
if nargin<5
    bias = 1.0;
end

if norFlag
    x = DspAlg.Normalize( signal, mn)/(sqrt(mn)-1);
else
    x = signal;
end

% get the size of input
mm = size(x,1);
kk = size(x,2);

% chose the estimator
switch estMeth
    case 'none'
        y = x;
        phEst = [];
    case {'lee','godard','sln','fln','avn'}
        % make sure that the length of x can be diveded by block-size
        temp = mod(mm,szBlock);
        if temp
            x = [ x; zeros(szBlock-temp,kk)];
        end
        [y, phEst]= PLL(x,sps,bias,szBlock,intMeth,estMeth, RectifyPolyCoff);
    otherwise
        error('DSPALG::FF_TPE unsupported estimator method')
end

% decimate the output or not
if decFlag
    y = y( 1:sps:end, :);
end


function [symRtm, tau]= PLL(x,sps,bias,szBlk,intMeth,estMeth, p)
%LEE_PLL This is NOT a phase lock loop

% Initialize 
for pol = 1:size(x,2)
    temp = 0;
    while (temp+1/sps-1/2)*(temp-1/2) >= 0
        px = x(1:szBlk,pol);
        if sum(strcmpi(estMeth,{'sln','fln','avn'})) && sps == 2
            % interpolation to get 4 samples per symbol using interpft
            px = interpft(px, 2*length(px));
        end
        px = RectifyPolyval(px, p);
        temp = TED(px, estMeth, bias);
        temp = -1/2/pi * angle(temp);
        id = floor((0.5-temp)*sps);
        x(:,pol) = circshift(x(:,pol), -id);
    end
end

%
x = [x;zeros(sps*10,size(x,2))];
pointer = ones(1,size(x,2)); % first index of basepoint set
k = 1;
ind = 0:szBlk-1;
while max(pointer)+szBlk+sps-2 <= size(x,1)
    
    for pol = 1:size(x,2)
        px = x(pointer(pol)+ind,pol);
        if sum(strcmpi(estMeth,{'sln','fln','avn'})) && sps == 2
            % interpolation to get 4 samples per symbol using interpft
            px = interpft(px, 2*length(px));
        end
        px = RectifyPolyval(px, p);
        
        % ================= TED =================== %
        sumcomp(k,pol) = TED(px, estMeth, bias);
        
        % ================= Loop Filter =================== %
        % % smooth the complex signal
        summation(k,pol) = loopfilter(sumcomp(:,pol));
        tau(k,pol) = -1/2/pi*angle(summation(k,pol));
        
        % ================= Control =================== %
        if k == 1 tau1 = 0;
        else tau1 = tau(k-1,pol);
        end
        tau2 = tau(k,pol);
        [pointer(pol), nu(k,pol), tau(k,pol)] = control(tau1, tau2, pointer(pol), sps);
        
        % ================= Interpolation =================== %
        % Sampling instants for tau calculation
        for n = 1:szBlk
            interpolantee = x(pointer(pol)+n-1:pointer(pol)+n+sps-2,pol);
            datInt(n,k,pol) = interpolate(interpolantee,nu(k,pol),intMeth);
        end
    end
    pointer = pointer+szBlk;
    k = k+1;
end
% format output
symRtm = reshape(datInt,[],size(x,2));


function y = interpolate(x,nu,method)
%INTERP Interpolate signal samples
%
sps = size(x,1);
if strcmpi(method,'linear') && sps == 2
    y = x(1,:) + nu*(x(2,:)-x(1,:));
elseif strcmpi(method,'cubic') && sps == 4
    b = [0 1 0 0;...
        -1/3 -1/2 1 -1/6;...
        1/2 -1 1/2 0;...
        -1/6 1/2 -1/2 1/6]; % b(i,l)
    v = b*x;
    y = ((v(4)*nu+v(3))*nu+v(2))*nu+v(1); 
elseif strcmpi(method,'parabolic') && sps == 4
    a = 0.5;
    b = [0 1 0 0;...
        -a a-1 a+1 -a;...
        a -a -a a]; % b(i,l)
    v = b*x;
    y = (v(3)*nu+v(2))*nu+v(1); 
elseif strcmpi(method,'none')
    y = x(1);
end

function y = loopfilter(x)
y = x(end);

function [pointer, nu, tau2] = control(tau1, tau2, pointer, sps)
if floor((0.5-tau2)*sps)
    if tau1-tau2>0.75
        pointer = pointer+1;    % skip one sample
        tau2 = tau2+(sps-1)/sps;
        nu = tau2*sps;
    elseif tau1-tau2<=0.25
        pointer = pointer-1;     % wait for one sample
        tau2 = tau2+1/sps;
        nu = tau2*sps;
    elseif tau1-tau2<=0.75 && tau1-tau2>0.5
        pointer = pointer+2;     % skip 2 sample
        tau2 = tau2+(sps-2)/sps;
        nu = tau2*sps;
    elseif tau1-tau2<=0.5 && tau1-tau2>0.25
        pointer = pointer-2;     % wait for 2 sample
        tau2 = tau2+2/sps;
        nu = tau2*sps;
    end
else
    nu = tau2*sps;
end
nu = mod(nu,1);

function s = TED(px, estMeth, g)

if nargin<3
    g = 1;
end

switch estMeth
    case 'fln'
        s = ted_fln(px);
    case 'sln'
        s = ted_sln(px);
    case 'avn'
        s = ted_avn(px);
    case 'lee'
        s = ted_lee(px,g);
    case 'godard'
        s = ted_godard(px);        
end

function s = ted_fln(px)
N = length(px);
k = 1:N;
ex = exp(-1j.*(k-1).*pi./2);
s = sum( abs(px).^4 .* ex.' );

function s = ted_sln(px)
N = length(px);
k = 1:N;
ex = exp(-1j.*(k-1).*pi./2);
s = sum( abs(px).^2 .* ex.' );

function s = ted_avn(px)
N = length(px);
k = 1:N;
ex = exp(-1j.*(k-1).*pi./2);
s = sum( abs(px) .* ex.' );

function s = ted_lee(px,g)
L = length(px);
n = 1:L;
% cosine part
ex1 = (-1).^(n-1);          % ex1 = exp(-1j.*(ii-1).*pi);
sum_1 = sum( abs(px).^2 .* ex1.' );
% sine part
ex2 = 1j * (-1).^(n-1);     % ex2 = exp(-1j.*(ii-1.5).*pi);
xh = px(2:end);
xx = px(1:end-1);
ex2 = ex2(1:end-1);
sum_2 = sum( real(conj(xx).*xh) .* ex2.' );
% with biasing
s = g*sum_1 + sum_2;

s = conj(s);

function s = ted_godard(px)
N = length(px);
X = fft(px);
Z = xcorr(X);
s = Z(N/2);
