function [BER, EVM] = bertMC(x, ref, mn, map, type)

if nargin < 5
    type = 'ber';
end

N = (sqrt(mn)-1)^2;
switch mn
    case 8
        h = modem.pskdemod('M', mn, 'SymbolOrder', map);
    otherwise
        h = modem.qamdemod('M', mn, 'SymbolOrder', map);
end

for n = 1:1
    
    if strcmpi(type,'ber')
        ref2 = demodulate(h,ref);
        x2 = demodulate(h,x * (1i)^(n-1));
        [~, ber(n), individual] = biterr(x2, ref2, log2(mn));
        evm(:,n) = ones(size(x,1),1);
    elseif strcmpi(type,'evm')
        ber(n) = 0.5;
        for m = 1:size(x,1)
            evm(m,n) = sqrt(mean(abs(x(m,:)-ref(m,:)).^2)/N);
        end
    elseif strcmpi(type,'ber/evm')
        ref2 = demodulate(h,ref);
        x2 = demodulate(h,x * (1i)^(n-1));
        [~, ber(n), individual] = biterr(x2, ref2, log2(mn));        
        for m = 1:size(x,1)
            evm(m,n) = sqrt(mean(abs(x(m,:)-ref(m,:)).^2)/N);
        end
    else 
        error('Illegal BER type');
    end
end

BER = min(ber);
[~, I] = min(sum(evm,1));
EVM = evm(:,I);