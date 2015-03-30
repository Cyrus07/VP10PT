function code = rs_enc(msg, N, K)
%RSENC Reed-Solomon encoder.
%
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use the comm.RSEncoder System object instead.
%
%
%   CODE = RSENC(MSG,N,K) encodes the message in MSG using an (N,K) Reed-
%   Solomon encoder with the narrow-sense generator polynomial. MSG is a Galois 
%   array of symbols over GF(2^m). Each K-element row of MSG represents a 
%   message word, where the leftmost symbol is the most significant symbol. If N 
%   is smaller than 2^m-1, then RSENC uses a shortened Reed-Solomon code. Parity
%   symbols are at the end of each word in the output Galois array code. 
%   
%   Examples:
%      n=7; k=3;                        % Codeword and message word lengths
%      m=3;                             % Number of bits per symbol
%      msg  = gf([5 2 3; 0 1 7],m)      % Two k-symbol message words
%      code = rsenc(msg,n,k)            % Two n-symbol codewords
%
%      genpoly = rsgenpoly(n,k);        % Default generator polynomial
%      code2 = rsenc(msg,n,k,genpoly);  % code and code1 are the same codewords
%
%   See also RSDEC, GF, RSGENPOLY.

% Copyright 1996-2012 The MathWorks, Inc.

% Fundamental checks on parameter data types
if isempty(N) || ~isnumeric(N) || ~isscalar(N) || ~isreal(N) || N~=floor(N) || N<3
    error(message('comm:rsenc:InvalidN'));
end
if N > 65535,
    error(message('comm:rsenc:InvalidNVal1'));
end
if isempty(K) || ~isnumeric(K) || ~isscalar(K) || ~isreal(K) || K~=floor(K) || K<1
    error(message('comm:rsenc:InvalidK'));
end
if isempty(msg)
    error(message('comm:rsenc:MsgEmptyGaloisArray'));
end;

M = log2(N+1);
% --- msg.m and its relationship with N
if M < 3
    error(message('comm:rsenc:InvalidMsgSymbols'));
end

t = (N-K)/2;
% --- t
if floor(t)~=t || t<1,
    error(message('comm:rsenc:InvalidNKDiff'));
end

T2 = 2*t;       % number of parity symbols

msg = reshape(msg,K,[]).';
msg = gf(msg,M); 
[m_msg, n_msg] = size(msg);

genpoly   = rsgenpoly(N,K,msg.prim_poly);
msgZ = msg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         %
%        ENCODING         %
%                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Pre-allocate memory
% Each row is a 2t-long register for parity symbols for the same row of msg
parity = gf(zeros(m_msg,T2),M,msg.prim_poly);

% First element (Coeff of X^T2) not used in algorithm.  (Always monic)
genpoly = genpoly(2:T2+1);

% Encoding
msgZ = fliplr(msgZ);
% Each row gives the parity symbols for each message word
for j=1:size(msgZ,2)
    parity = [parity(:,2:T2) zeros(m_msg,1)] + (msgZ(:,j)+parity(:,1))*genpoly;
end

% Make codeword by appending / prepending parity to msg
code = [msgZ parity];
code = fliplr(code);

code = double(code.x);
% -- end of rsenc --
