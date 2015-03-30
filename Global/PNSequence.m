function Seq = PNSequence(varargin)

Type = varargin{1};

switch Type
    case 'ZadoffChu'
        Seq = SeqZadoffChu(varargin{2:end});
    case 'Golay'
        Seq = SeqGolay(varargin{2:end});
    case 'mSeq'
        if varargin{end} == 0
            Seq = (1:0).';
        else
            Seq = SeqM(2,ceil(log2(varargin{end})),10);
            Seq = [Seq(1); Seq];
        end
    case 'Frank'
        Seq = SeqFrank(varargin{2:end});
    case 'NewmanPhase'
        Seq = SeqNewmanPhase(varargin{2:end});
    case 'Walsh'
        Seq = SeqWalsh(varargin{2:end});
    case 'QPSK'
        Seq = SeqQPSK(varargin{2:end});
end

function seq = SeqFrank(n, r)

% r should be relatively prime with repect to L
if nargin < 2; r = 1; end
q = ceil(sqrt(n));
L = q^2;
for k = 0:L-1
    phase(k+1) = 2*pi/q*r*rem(k,q)*floor(k/q);
end
seq = exp(1i*phase).';
seq = seq(1:n);

function [a, b] = SeqGolay(N, BitPerSymbol)

if nargin < 2; BitPerSymbol = 2; end
    
tmp = ceil(log2(N));
switch BitPerSymbol
    case 1
        a = [1 1];
        b = [1 -1];
    case 2
        a = [1+1i 1+1i];
        b = [1+1i -1-1i];
end

while tmp > 1
    tmpa = a;
    tmpb = b;
    a = [tmpa tmpb];
    b = [tmpa -tmpb];
    tmp = tmp - 1;
end
a = a(1:N).';
b = b(1:N).';

function seq = SeqNewmanPhase(N)

k = 1:N;
phase = pi*(k-1).*(k-1)/N;
seq = exp(1i*phase).';

function seq = SeqQPSK(N)

Seq = SeqM(2,log2(N)+1);
seq = [Seq(1); Seq];
seq = seq(1:end/2) + 1i*seq(end/2+1:end);

function seq = SeqWalsh(N, m)

if nargin < 2; m = N; end
k = ceil(log2(N));

seq=1;
for i = 1:k
    seq(1:2^(i-1),(2^(i-1)+1):2^i) = seq(1:2^(i-1),1:2^(i-1));
    seq((2^(i-1)+1):2^i,1:2^(i-1)) = seq(1:2^(i-1),1:2^(i-1));
    seq((2^(i-1)+1):2^i,(2^(i-1)+1):2^i) = -seq(1:2^(i-1),1:2^(i-1));
end

seq = seq(:,end-m+1:end);% size = Nch*Nuser

function seq = SeqZadoffChu(N, p)

% p should be relatively prime with repect to N
if nargin < 2; p = 1; end

k = 0:N-1;
if mod(N,2)==0
    phase = pi*k.*k*p/N;
else
    phase = pi*(k+1).*k*p/N;
end
seq = exp(1i*phase).';

% seq = seq .* exp(1i*pi/4);
