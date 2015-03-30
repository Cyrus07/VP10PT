function [y,tpn] = FeedforwardTPE(x,sps,Seq,te,estMeth,intMeth)

if nargin<6
    intMeth = 'parabolic';
end
if nargin<5
    estMeth = 'none';
end

% chose the estimator
switch estMeth
    case 'none'
        y = x(te:sps:end,:);
%         tmp = repmat(x,[1,1,sps]);
%         for p = 1:sps
%             tmp(:,:,p) = circshift(tmp(:,:,p),[-(p-1),0,0]);
%         end
%         y = sum(tmp,3);
%         y = y(te:sps:end,:);
        tpn = [];
    case 'JWang'
        % make sure that the length of x can be diveded by block-size
        for ii = 1:size(x,2)
            [y(:,ii), tpn(:,ii)]= PLL(x(:,ii),sps,Seq(ii,:).',te,intMeth,estMeth);
        end
    otherwise
        error('DSPALG::FF_TPE unsupported estimator method')
end


function [symRtm, tau]= PLL(x,sps,Seq,te,intMeth,estMeth)
%LEE_PLL This is NOT a phase lock loop
Seq2 = reshape(repmat(Seq.',sps,1),1,[]).';
N = length(Seq2);
% Initialize 
for d = max(te-N/2,1) : te+N/2
    R(d) = Seq2'*x(d:d+N-1,1);
end
m = find(abs(R) == max(abs(R)),1);

% ================= TED =================== %
switch estMeth
    case 'JWang'
        tau = ted_JWang(R(m-3:m+3));
    otherwise
end

% ================= Control =================== %
% tau = tau-0.16;
Smin = -0.52;
Smax = 0.56;
a = 1/(Smax-Smin);
b = 0.5 - Smax*a;
nu = (a*tau+b)+0.5;
% nu = tau+0.5;
    
% ================= Interpolation =================== %
% Sampling instants for tau calculation
x = x(m:end);
x = x(1:floor(end/sps)*sps);
xsps = reshape(x,sps,[]).';
y = interpolate(xsps,nu,intMeth);

% format output
symRtm = y;


function tau = ted_JWang(R)
d0 = abs(R(6)) - abs(R(2));
d_1 = abs(R(5)) - abs(R(1));
d1 = abs(R(7)) - abs(R(3));
tau = 2*d0/(d_1-d1);

function y = interpolate(x,nu,method)
%INTERP Interpolate signal samples
%
sps = size(x,2);
if strcmpi(method,'linear') && sps == 2
    y = x(:,1) + nu*(x(:,2)-x(:,1));
elseif strcmpi(method,'cubic') && sps == 4
    C(4,1) = nu^3/6-nu/6;
    C(3,1) = -nu^3/2+nu^2/2+nu;
    C(2,1) = nu^3/2-nu^2-nu/2+1;
    C(1,1) = -nu^3/6+nu^2/2-nu/3;
    y = x*C;
elseif strcmpi(method,'parabolic') && sps == 4
    a = 0.5;
    C(4,1) = a*nu^2-a*nu;
    C(3,1) = -a*nu^2+(a+1)*nu;
    C(2,1) = -a*nu^2+(a-1)*nu+1;
    C(1,1) = a*nu^2-a*nu;
    y = x*C;
elseif strcmpi(method,'none')
    y = x(:,sps/2);
end