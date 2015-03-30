function [y, ce] = ChannelEstimator(x, cetype, objCE, objCoder)
pol = size(x,2);
% get channel response
[~, TrainMat] = objCE.TrainChannelEst;

x = x(round(objCE.NumGI/2)+1:end,:);
training = x(1:objCE.CEBlock*pol*(objCE.NumFFT+objCE.NumGI),:);
switch cetype
    case 'ISTA'
        ce = DspAlg2.CEISTA(training, objCE.NumFFT, objCE.NumGI, objCE.CEBlock, TrainMat);
    case 'Lms'
        ce = DspAlg2.CELms(training, objCE.NumFFT, objCE.NumGI, objCE.CEBlock, TrainMat);
    case 'ISFA'
        ce = DspAlg2.CEISTA(training, objCE.NumFFT, objCE.NumGI, objCE.CEBlock, TrainMat);
        ce = DspAlg2.CEISFA(ce, taps, objCE.CEFFT);
end

% equalize
payload = x(1+objCE.CEBlock*pol*(objCE.NumFFT+objCE.NumGI):end,:);
nblock = floor(size(payload,1)/(objCoder.NumFFT+objCoder.NumGI));
if pol == 1
    data = payload(1:(objCoder.NumFFT+objCoder.NumGI)*nblock,:);
    dataMat = reshape(data, objCoder.NumFFT+objCoder.NumGI, []);
    dataMat = dataMat(1:objCoder.NumFFT,:);
    mat = fft(dataMat);
    for n = 1:nblock
        y([objCoder.IndPilot;objCoder.IndSubCarr],n) ...
            = mat([objCoder.IndPilot;objCoder.IndSubCarr],n) ...
            .* ce([objCoder.IndPilot;objCoder.IndSubCarr],1);
    end
    
elseif pol == 2
    data = payload(1:(objCoder.NumFFT+objCoder.NumGI)*nblock,:);
    dataMat = reshape(data(:,1), objCoder.NumFFT+objCoder.NumGI, []);
    dataMat = dataMat(1:objCoder.NumFFT,:);
    mat{1} = fft(dataMat);
    dataMat = reshape(data(:,2), objCoder.NumFFT+objCoder.NumGI, []);
    dataMat = dataMat(1:objCoder.NumFFT,:);
    mat{2} = fft(dataMat);
    clear tmp
    for n = 1:nblock
        y(:,[objCoder.IndPilot;objCoder.IndSubCarr],n) = DspAlg2.Equalize(...
            ce([objCoder.IndPilot;objCoder.IndSubCarr],:,:),...
            [mat{1}([objCoder.IndPilot;objCoder.IndSubCarr],n) mat{2}([objCoder.IndPilot;objCoder.IndSubCarr],n)]).';
    end
end

end