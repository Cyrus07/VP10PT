classdef BERTDualPol < BERT
    %BERTESTING Count the number of bit error
    %   Copyright2010 WANGDAWEI $16/3/2010$
    %   Last modification 2014, Lingchen
    
    properties
        Method  = 'Gray'      % Gray, Binary, Diff
        EC      = 0
        ER
        ERId
        EVM
        PolFlip
    end
    
    methods
        function reset(~)
        end
        
        function RXHat = Output(obj, RecVec, RefMat, mn)
            RecVec = DspAlg.Normalize(RecVec,mn);
              
            if obj.PolFlip
                RecVec = fliplr(RecVec);
            end
            
            for pol = 1 : size(RecVec,2)
                rx = RecVec(:,pol);
                txp = obj.CorrTxRx(RefMat(:,pol), rx);
                if isempty(txp)
                    obj.EC(pol) = NaN;
                    obj.ER(pol) = 0.5;
                    obj.ERId{pol} = NaN;
                    obj.EVM(pol) = NaN;
                    continue;
                end
                    
                if strcmpi(obj.Method,'binary') || strcmpi(obj.Method,'gray')
                    rxbits = matlab_demod(rx,mn,obj.Method);
                    for kr = 1:4
                        rt = 1i^(kr-1);
                        txbits = matlab_demod(txp*rt,mn,obj.Method);
                        [ecp(kr), erp(kr), Ind(:,kr)] = biterr(rxbits, txbits);
                    end
                    [~, ind] = min(erp);
                    obj.EC(pol) = ecp(ind);
                    obj.ER(pol) = erp(ind);
                    obj.ERId{pol} = find(Ind(:,ind)==1);
                    clear ecp erp Ind;
                    rt = 1i^(ind-1);
                    RXHat(:,pol) = txp*rt;
                    N = (sqrt(mn)-1)^2;
                    obj.EVM(pol) = sqrt(mean(abs(RXHat(:,pol)-rx).^2)/N);
                elseif strcmpi(obj.Method,'diff')
                    rxbits = matlab_demod(rx,mn,'binary');
                    rxbits = reshape(rxbits,log2(mn),[]).';
                    rxbits = DspAlg.DifferentialDecode(rxbits, mn);
                    txbits = matlab_demod(txp,mn,'binary');
                    txbits = reshape(txbits,log2(mn),[]).';
                    txbits = DspAlg.DifferentialDecode(txbits, mn);
                    [EC(pol), ER(pol), ERId(:,pol)] = biterr(rxbits, txbits);
                end
            end
        end
        
        function txp = CorrTxRx(obj, tx, rx)
            dataLength = length(tx);
            if length(rx)<dataLength
                rx2 = [rx; zeros(dataLength-length(rx),1)];
                normLength = length(rx2);
            else
                rx2 = rx(1:dataLength);
                normLength = dataLength;
            end
            xcorrel = abs(ifft(fft(conj(flipud(tx))).*fft(rx2)))/normLength;
            % plot(xcorrel);
            [maxCorr, IndCorr] = max(xcorrel);
            if maxCorr<1/2
                txp = [];
                return;
            end
            syncInd = IndCorr - dataLength + 1;
            while(syncInd > 1)
                syncInd = syncInd - dataLength;
            end
            
            nframe = ceil(((1-syncInd)+length(rx))/dataLength);
            txtmp = repmat(tx,nframe,1);
            txp = txtmp(2-syncInd:2-syncInd+length(rx)-1);
        end
            
    end
end
