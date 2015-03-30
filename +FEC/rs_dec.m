function [decoded, cnumerr, ccode] = rs_dec(code, N, K, dectype)
%RSDEC Reed-Solomon decoder.
%
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use the comm.RSDecoder System object instead.
%
%   DECODED = RSDEC(CODE,N,K) attempts to decode the received signal in CODE 
%   using an (N,K) Reed-Solomon decoder with the narrow-sense generator 
%   polynomial. CODE is a Galois array of symbols over GF(2^m), where m is the
%   number of bits per symbol. Each N-element row of CODE represents a 
%   corrupted systematic codeword, where the parity symbols are at the end and 
%   the leftmost symbol is the most significant symbol. If N is smaller than 
%   2^m-1, then RSDEC assumes that CODE is a corrupted version of a shortened 
%   code.
%   
%   In the Galois array DECODED, each row represents the attempt at decoding the 
%   corresponding row in CODE. A decoding failure occurs if a row of CODE 
%   contains more than (N-K)/2 errors. In this case, RSDEC forms the 
%   corresponding row of DECODED by merely removing N-K symbols from the end of 
%   the row of CODE.
%
%   Example:
%      n=7; k=3;                          % Codeword and message word lengths
%      m=3;                               % Number of bits per symbol
%      msg  = gf([7 4 3;6 2 2;3 0 5],m)   % Three k-symbol message words
%      code = rsenc(msg,n,k);             % Two n-symbol codewords
%      % Add 1 error in the 1st word, 2 errors in the 2nd, 3 errors in the 3rd
%      errors = gf([3 0 0 0 0 0 0;4 5 0 0 0 0 0;6 7 7 0 0 0 0],m);
%      codeNoi = code + errors
%      [dec,cnumerr] = rsdec(codeNoi,n,k) % Decoding failure : cnumerr(3) is -1
%
%   See also RSENC, GF, RSGENPOLY.

% Copyright 1996-2012 The MathWorks, Inc.

% Fundamental checks on parameter data types
if isempty(N) || ~isnumeric(N) || ~isscalar(N) || ~isreal(N) || N~=floor(N) || N<3
    error(message('comm:rsdec:InvalidN'));
end
if N > 65535,
    error(message('comm:rsdec:InvalidNVal1'));
end
if isempty(K) || ~isnumeric(K) || ~isscalar(K) || ~isreal(K) || K~=floor(K) || K<1
    error(message('comm:rsdec:InvalidK'));
end

% Find fundamental parameters m and t
M = log2(N+1);
if M < 3
    error(message('comm:rsdec:InvalidCodeSymbol'));
end

t = (N-K)/2;
% --- t
if floor(t)~=t || t<1,
    error(message('comm:rsdec:InvalidNKDiff'));
end

% --- code
if isempty(code)
    error(message('comm:rsdec:CodeEmptyGaloisArray'));
end;

if nargin < 4
    dectype = 'berlekamp';
end
% Reed-Solomon decoding
switch lower(dectype)
    case 'berlekamp'
        % Call to core algorithm berlekamp
        for j = 1 : size(code,1)
            [decoded(j,:), cnumerr(j), ccode(j,:)] ...
                = FEC.rs_dec_berlekamp(code(j,:),N,K,M,t);
        end
    case 'euclidean'
        % Call to euclidean
        for j = 1 : size(code,1)
            [decoded(j,:), cnumerr(j), ccode(j,:)] ...
                = FEC.rs_dec_euclidean(code(j,:),N,K,M,t);
        end
end

