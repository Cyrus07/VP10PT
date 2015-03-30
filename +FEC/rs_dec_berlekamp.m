function [decodedInt, cnumerr, ccodeInt] = rs_dec_berlekamp(code,N,K,M,t)
% Error Control Coding 2rd edition, Chinese Version, pp 163, example 7-2
% example: r = [0 0 0 alpha^7 0 0 alpha^3 0 0 0 0 0 alpha^4 0 0]
% code = gf([0 0 0 11 0 0 8 0 0 0 0 0 3 0 0],M,code.prim_poly);
% the mapping can be found on pp 31, the integer is expressed by binary
% vector with 'left-msb' order.

T2 = 2*t;
code = gf(code,M);
%% syndrome
alpha = gf(2,M,code.prim_poly);
% alphai = alpha.^(b-1+(1:T2));
% S = ones(1,T2) * code(N);
% for n = N-1:-1:1
%     S = S.*alphai + code(n);
% end

powerMat = (1:T2).'*(0:N-1);
alphai = alpha.^powerMat;
S = code * alphai.';

if ~sum(S.x)
    cnumerr = 0;
    ccodeInt = code;
    decodedInt = ccodeInt(T2+1:N);
    ccodeInt = double(ccodeInt.x);
    decodedInt = double(decodedInt.x);
    return;
end
%% error-position evaluator
%% mu = -1
% sigma(mu) := sigma(mu+2,:)
sigma= gf(zeros(T2+1,T2+1),M);
sigma(1,1) = 1;
% d(mu) := d(mu+2,:)
d = gf(zeros(1,T2),M);
d(1) = 1;
% l(mu) := l(mu+2,:)
l(1) = 0;
%% mu = 0
sigma(2,1) = 1;
d(2) = S(1);
l(2) = 0;
% mu - l(mu) := mu_l
mu_l = 0;
rho = -1;

%% mu := mu
gf0= gf(0,M);
for mu = 0:T2-2
    d(mu+2)=S(mu+1)+S(mu:-1:mu-l(mu+2)+1)*sigma(mu+2,2:l(mu+2)+1).';
    if d(mu+2) == gf0
        sigma(mu+3,:) = sigma(mu+2,:);
        l(mu+3)=l(mu+2);
    else
        sigma(mu+3,:) = sigma(mu+2,:) + ...
            d(mu+2)/d(rho+2)*circshift(sigma(rho+2,:),[0 mu-rho]);
        l(mu+3) = max(l(mu+2),mu-rho+l(rho+2));
        if mu-l(mu+2) >= mu_l
            mu_l = mu-l(mu+2);
            rho = mu;
        end
    end
    dmu = d(max(mu+3-t+l(mu+2),1):mu+2);
    if ~sum(dmu.x)
        break;
    end
end
% mu = T2 - 1
mu = mu + 1;
d(mu+2)=S(mu+1)+S(mu:-1:mu-l(mu+2)+1)*sigma(mu+2,2:l(mu+2)+1).';
if d(mu+2) == gf0
    sigma(mu+3,:) = sigma(mu+2,:);
else
    sigma(mu+3,:) = sigma(mu+2,:) + ...
        d(mu+2)/d(rho+2)*circshift(sigma(rho+2,:),[0 mu-rho]);
end

%% pinpoint error position
cnumerr = l(mu+2);
sigmax = sigma(mu+3,1:cnumerr+1);

alpha = gf(2,M);
powerMat = (1:N).'*(0:cnumerr);
alphai = alpha.^powerMat;
sigma0 = sigmax*alphai.';
root = N - find(sigma0==0);
cnumroot = length(root);

%% error number larger than t
if ~cnumroot
    cnumerr = -1;
    ccodeInt = code;
    decodedInt = ccodeInt(T2+1:N);
    ccodeInt = double(ccodeInt.x);
    decodedInt = double(decodedInt.x);
    return;
end
%% error-value evaluator
z = conv(S(1:cnumroot), sigmax(1:cnumroot));
z = z(1:cnumroot);

alpha = gf(2,M);
powerMat = (-root).'*(0:cnumroot-1);
alphai = alpha.^powerMat;
zx = z*alphai.';
beta = alpha.^(ones(cnumroot,1)*root - root.'*ones(1,cnumroot));
beta = 1 - beta;
beta = beta + diag(alpha.^root);
betax = beta(:,1);
for n = 2:cnumroot
    betax = betax.*beta(:,n);
end

error = gf(zeros(1,N),M);
error(root+1) = zx./betax.';

ccodeInt = code - error;
decodedInt = ccodeInt(T2+1:N);
ccodeInt = double(ccodeInt.x);
decodedInt = double(decodedInt.x);