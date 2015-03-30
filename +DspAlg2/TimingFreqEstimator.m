function [y, te, fe]= TimingFreqEstimator(x, obj, frequency, sps, th)

if (obj.Active && obj.TFETraningActive)
    switch obj.TimingFreqEst
        case 'Minn'
            [y, te, fe] ...
                = DspAlg2.TEFEMinn(x, obj.TFESeqType, obj.TFEBlock, ...
                obj.TFEFFT, obj.TFEPattern, sps, th);
        case 'SCA'
            [y, te, fe] ...
                = DspAlg2.TEFESCA(x, obj.TFESeqType, sps, obj.TFEFFT, obj.TFEFFT/8, th);
        otherwise
    end
else
    te = obj.TimeDelay*sps+1;
    fe = -1*frequency;
    y = x.*exp(-1i*2*pi*fe*(1:size(x,1)).'*ones(1,size(x,2)));
    y = y(te:end,:);
end

end