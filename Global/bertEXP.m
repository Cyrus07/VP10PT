function [BER, EVM, BERD] = bertEXP(x, Ref, mn, map)

if nargin < 4
    map = 'Gray';
end

if isreal(Ref{1})
    h = modem.qammod('M', mn);
    h.SymbolOrder = map;
    h.InputType = 'Integer';
    for n = 1:length(Ref)
        symRef{n} = reshape(Ref{n},[],1);
        csRef{n} = h.modulate(symRef{n});
    end
else
    h = modem.qamdemod('M', mn);
    h.SymbolOrder = map;
    h.OutputType = 'Integer';
    for n = 1:length(Ref)
        csRef{n} = reshape(Ref{n},[],1);
        symRef{n} = h.demodulate(csRef{n});
    end
end

cut = min(size(x,1)/4,5e3);
x = x(cut+1:end-cut,:);
N = (sqrt(mn)-1)^2;
h = modem.qamdemod('M', mn);
% h.SymbolOrder = map;
dataLength = length(csRef{1});

for pol = 1:size(x,2);
    xcorrel = abs( xcorr(x(1:dataLength,pol),csRef{pol}));
    syncInd = find(xcorrel == max(xcorrel)) - dataLength + 1;
    while(syncInd < 0)
        syncInd = syncInd + dataLength;
    end
    numframe = floor((size(x,1)-syncInd)/dataLength);
    
    dataInd = (0:dataLength-1) + syncInd;
    for f = 1:numframe
        x2 = x(dataInd+(f-1)*dataLength,pol);
        for n = 1:4
            tmp = x2 * (1i)^(n-1);
            % binary decoding
            h.OutputType = 'int';
            x3 = h.demodulate(tmp);
            [~, bern(n)] = biterr(x3, symRef{1});
            %         a = xor(x3(:,1),symRef{1});plot(a);
            % EVM
            evmn(n) = sqrt(mean(abs(tmp-csRef{pol}).^2)/N);
        end
        % differential decoding
        h.OutputType = 'bit';
        x4 = h.demodulate(x2);
        y1 = h.demodulate(csRef{1});
        x5 = reshape(x4(:,1),log2(mn),[]).';
        y1 = reshape(y1,log2(mn),[]).';
        x5 = DspAlg.DifferentialDecode(x5,mn);
        y1 = DspAlg.DifferentialDecode(y1,mn);
        [~, bernd] = biterr(x5, y1);
        % a = xor(reshape(x5.',[],1),reshape(y1.',[],1));plot(a);
        
        berf(f) = min(bern);
        berfd(f) = bernd;
        evmf(f) = min(evmn);
        clear bern bernd evmn;
    end
    if max(berf)>0
        BER(pol) = mean(berf(find(berf<min(berf(find(berf>0)))*2)));
    else
        BER(pol) = 0;
    end
    EVM(pol) = mean(evmf(find(evmf<min(evmf(find(evmf>0)))*2)));
    
    BERD(pol) = mean(berfd);
    clear berf berfd evmf;
end

