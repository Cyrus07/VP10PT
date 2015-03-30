function [decodedInt, cnumerr, ccodeInt] = rs_dec_euclidean(code,N,K,M,t)
% Error Control Coding 2rd edition, Chinese Version, pp 163, example 7-2
% example: r = [0 0 0 alpha^7 0 0 0 0 0 0 alpha^11 0 0 0 0]
% M = 4; N = 15; K = 9; t = 3;
% code = gf([0 0 0 11 0 0 0 0 0 0 14 0 0 0 0],M);
% the mapping can be found on pp 31, the integer is expressed by binary
% vector with 'left-msb' order.

T2 = 2*t;
code = gf(reshape(code,1,[]),M);
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
%% euclidean algorithm
z0 = gf([1, zeros(1, T2)], M);
z1 = fliplr(S);
ind = find(z1~=0,1);
z1 = z1(ind:end);
sigma0 = gf(0, M);
sigma1 = gf(1, M);
[q, z2] = deconv(z0, z1);
ind = find(z2~=0,1);
z0 = z1; z1 = z2(ind:end);
sigma2 =  - conv(q, sigma1);
sigma2 = [zeros(1,length(sigma2)-length(sigma0)), sigma0] + sigma2;
ind = find(sigma2~=0,1);
sigma0 = sigma1; sigma1 = sigma2(ind:end);
for i = 1:T2-2
    if  length(z1) < length(sigma1)
        break;
    end
    [q, z2] = deconv(z0, z1);
    ind = find(z2~=0,1);
    z0 = z1; z1 = z2(ind:end);
    sigma2 =  - conv(q, sigma1);
    sigma2 = [zeros(1,length(sigma2)-length(sigma0)), sigma0] + sigma2;
    ind = find(sigma2~=0,1);
    sigma0 = sigma1; sigma1 = sigma2(ind:end);
end
z = fliplr(z1);
sigmax = fliplr(sigma1);
cnumerr = length(sigmax)-1;

%% pinpoint error position
alpha = gf(2,M,code.prim_poly);
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
alpha = gf(2,M,code.prim_poly);
powerMat = (-root).'*(0:length(z)-1);
alphai = alpha.^powerMat;
zx = z*alphai.';
beta = alpha.^(ones(cnumroot,1)*root - root.'*ones(1,cnumroot));
beta = 1 - beta;
beta = beta + diag(alpha.^root);
betax = beta(:,1);
for n = 2:cnumroot
    betax = betax.*beta(:,n);
end

error = gf(zeros(1,N),M,code.prim_poly);
error(root+1) = zx./betax.'/sigmax(1);

ccodeInt = code - error;
decodedInt = ccodeInt(T2+1:N);
ccodeInt = double(ccodeInt.x);
decodedInt = double(decodedInt.x);