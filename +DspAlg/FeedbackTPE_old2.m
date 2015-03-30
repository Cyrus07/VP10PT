

function [y,tau,err] = FeedbackTPE(signal,mn,sps,delta,estMeth,intMeth,decFlag,norFlag, RectifyPolyCoff)
%TIMINGRECOVERY Summary of this function goes here
%   mn: modulation order
%   mu: step size
%   estMeth: estimator method
%   intMeth: interpolation method
%
%   Example
%   
%   See also FeedforwardTPE

%   Copyright2010 WANGDAWEI 16/3/2010
if nargin<9
    RectifyPolyCoff = [];
end
if nargin<8
    norFlag = 1;
end
if nargin<7
    decFlag = 1;
end
if nargin<6
    intMeth = 'linear';
end
if nargin<5
    estMeth = 'gardner';
end

% normalize the input or not
if norFlag
    x = DspAlg.Normalize( signal, mn)/(sqrt(mn)-1);
else
    x = signal;
end

% get the size of input
mm = size(x,1);
kk = size(x,2);

% chose the estimator
switch lower(estMeth)
    case 'none'
        y       = x(1:sps:end,:);
        tau     = zeros(1,kk);
        err     = zeros(1,kk);
    case 'gardner'
        % make sure that the length of x can be diveded by sps
        temp = mod(mm, sps);
        if temp
            x = [x;zeros(sps-temp,kk)];
        end
        
%         [y,tau,err] = GardnerPLL(x,sps,delta,intMeth);
%         for d = 1:size(x,2)
%             [y(:,d),tau(:,d),err(:,d)] = GardnerPLL(x(:,d),sps,delta,intMeth);
%         end
        for d = 1:size(x,2)
            [y{d},tau{d},err{d}] = GardnerPLL(x(:,d),sps,delta,intMeth,RectifyPolyCoff);
        end
        if size(x,2) == 2
            y = [y{1}(1:min(size(y{1},1),size(y{2},1))) y{2}(1:min(size(y{1},1),size(y{2},1)))];
            tau = [tau{1}(1:min(size(tau{1},2),size(tau{2},2))); tau{2}(1:min(size(tau{1},2),size(tau{2},2)))].';
            err = [err{1}(1:min(size(err{1},2),size(err{2},2))); err{2}(1:min(size(err{1},2),size(err{2},2)))].';
        else
            y = y{1};tau = tau{1}.';err = err{1}.';
        end
end
if decFlag
    y = y(1:2:end,:);
end

function [y,tau,err] = GardnerPLL(x,sps,delta,method, p)
%GARDNERPLL Gardner timing error detector
%
Initial = 0.01;

LoopDelay = 1;
y       = x(1:LoopDelay*sps,:);
nu      = Initial*2*ones(LoopDelay,1);
m       = sps*LoopDelay+1;
tau  	= Initial*ones(LoopDelay,1);
err   	= 0*ones(LoopDelay,1);
k       = LoopDelay+1;
x       = [x; zeros(sps,size(x,2))];
while m+sps/2+1<=size(x,1)
    
    % ================= Interpolation =================== %
    % Sampling instants for tau calculation
    for n = 1:sps
        interpolantee = x(m-sps/2+n:m+sps/2+n-1,:);
        y(sps*(k-1)+n,:) = interpolate(interpolantee,nu(k-LoopDelay),method);
    end

    % ================= TED =================== %
    % Gardner
    px = y(sps*k-3:sps*k-1,:);
    px = RectifyPolyval(px, p);
    err(k) = ted_Gardner(px);
    
%     % Modified timing error detector
%     err(k) = ted_ModifiedGardner(y(m-2:m,:))

    % ================= Loop Filter =================== %
    tau(k) = tau(k-1) + loopfilter(err(k-LoopDelay:k), delta);
    % wrap timing phase
    if tau(k) > 1/sps
        tau(k) = tau(k) -1;
    end
    % ================= Control =================== %
    [m, nu(k), tau(k)] = control(tau(k-1), tau(k), m, sps);
    
    k = k+1;
end
% pause(0.01);
% plot(err(1:k));hold on;
% plot(tau(1:k),'r');
% plot(nu(1:k),'k');

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
end

function err = ted_Gardner(x)
eK = real( (x(1,:) - x(3,:)) .* conj(x(2,:)) );
err = mean(eK);

function err = ted_ModifiedGardner(x)
% The modified version is refered to:
% [1] W. Gappmair, S. Cioni, G. E. Corazza, and O. Koudelka, "Symbol-Timing
% Recovery with Modified Gardner Detectors," in International Symposium on
% Wireless Communication Systems, 2005, pp. 831-834.
%
% When mu = 1, the ted reduce to the normal gardner ted.
mu = 1;
eK = real((abs(x(1,:)).^ mu.* exp(1i*angle(x(1,:)))-abs(x(3,:)).^ mu.* exp(1i*angle(x(3,:))))...
    .* conj(x(2,:)) );
err = mean(eK);

function y = loopfilter(x, delta)
y = x(end)*delta;

function [m,nu,tau2] = control(tau1, tau2, m, sps)
if floor((0.5-tau2)*sps)
    if tau1-tau2>0.75
        m = m+1;    % skip one sample
        tau2 = tau2+(sps-1)/sps;
        nu = tau2*sps;
    elseif tau1-tau2<=0.25
        m = m-1;     % wait for one sample
        tau2 = tau2+1/sps;
        nu = tau2*sps;
    end
else
    nu = tau2*sps;
end
nu = mod(nu,1);
m = m+sps;