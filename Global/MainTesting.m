function [RTMOUT CMAOUT CPEOUT df TPE_PHASE CMA_MSE CPE_PN] = MainTesting( ...
    symRate, constPoint, samplingRate, ...
    Pa_eye, Pa_OTH, Pa_LPF, Pa_CMA, Pa_CPE, Pa_TPE, Pa_DCF, Pa_FOC, ...
    FiberLength, paramGVD, Pa_Bw, ...
    TPE_config,TPE_blk, TPE_bias, TPE_gain, TPE_estMeth, TPE_intMeth, TPE_decFlag, ...
    CPE_config,CPE_gain,CPE_Method, CPE_Length, CPE_appML, CPE_iter, ...
    CMA_gain,CMA_taps,CMA_errID,CMA_iter,CMA_appLMS,LMS_iter,LMS_gain,LMS_taps, ...
    xi, xq, yi, yq)
%MAINTESTING Main testing funtion for offline processing of the
%   experimental results. Using circular boundary condition for
%   CMA convergence. 
%   The unit of FiberLength is [km]
%   The unit of paramGVD is [ps/nm/km]
%   The unit of symRate & samplingRate is [Hz]
%
%   Example
%
%   See also

%   copyright2012 wangdawei 2012/7/4

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% I,Q normalization
[xi xq yi yq] = SignalPrenormalize(xi,xq,yi,yq);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if Pa_eye
%     ShowEyediagram(xi,xq,symRate,samplingRate)
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LPF first
if Pa_LPF
    [xi xq yi yq] = LowpassFilter(samplingRate,Pa_Bw,xi,xq,yi,yq);
end
REAL_DATA = [xi,xq,yi,yq];
% sps = round(samplingRate/symRate);
% for ii = 1:sps, figure; plot(xi(ii:sps:end),xq(ii:sps:end),'.'); end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Pa_eye
    ShowEyediagram(xi,xq,symRate,samplingRate)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Digital resampling
sps = 2;
[up down] = rat( symRate * sps / samplingRate );
if up == down
    RSP_TMP = REAL_DATA;
% elseif up == 1
%     RSP_TMP = REAL_DATA(1:down:end,:);
else
    RSP_TMP = resample(REAL_DATA, up, down);
end
COMPLEX_DATA = [RSP_TMP(:,1)+1j*RSP_TMP(:,2),RSP_TMP(:,3)+1j*RSP_TMP(:,4)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Pa_OTH
    OTH_OUT = DspAlg.Orthogonal(COMPLEX_DATA);
else
    OTH_OUT = COMPLEX_DATA;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Chromatic dispersion compensation
if Pa_DCF
    dispertion = paramGVD * FiberLength * 1e-3;
    Fs = symRate * sps;
    Fc = 299792458/1550.12e-9;
    DCF_OUT = DspAlg.FrequencyDCF(OTH_OUT,dispertion,Fc,Fs,512,'ideal');
else
    DCF_OUT = OTH_OUT;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Timing phase recovery
if Pa_TPE
    norFlag = 0;
    switch TPE_config
        case 'feedforward'
            [TPE_OUT TPE_PHASE] = DspAlg.FeedforwardTPE(DCF_OUT, ...
                constPoint,sps, ...
                TPE_blk,TPE_bias,TPE_estMeth,TPE_intMeth,TPE_decFlag,norFlag);
        case 'feedback'
            [TPE_OUT TPE_PHASE] = DspAlg.FeedbackTPE(DCF_OUT, ...
                constPoint,sps, ...
                TPE_gain,TPE_estMeth,TPE_intMeth,norFlag);
    end
else
    TPE_OUT = DCF_OUT;    TPE_PHASE = [];
end
sps = sps - Pa_TPE*(sps-1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Polarizaton demultiplexing
if Pa_CMA
    polmux = 1;
    [CMA_OUT CMA_MSE] = DspAlg.PolarizationDemux(TPE_OUT, ...
        constPoint,sps,polmux, CMA_gain,CMA_taps,CMA_errID,CMA_iter,0);
else
    CMA_OUT = TPE_OUT;    CMA_MSE = [];
end
sps = sps - Pa_CMA*(sps-1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Frequency offset compensation
if Pa_FOC
    [CMA_OUT df] = DspAlg.FeedforwardFOC(CMA_OUT,symRate);
else
    df = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Carrier phase recovery
if Pa_CPE
    % CMA_OUT = DelayInterferometer( CMA_OUT, sps );
    switch CPE_config
        case 'feedforward'
            [CPE_OUT CPE_PN] = DspAlg.FeedforwardCPE(CMA_OUT, ...
                constPoint,CPE_Length,CPE_Method,CPE_appML,CPE_iter);
        case 'feedback'
            [CPE_OUT CPE_PN] = DspAlg.FeedbackCPE(CMA_OUT, ...
                constPoint,CPE_gain,[0,0],CPE_appML,CPE_iter);
    end
else
    CPE_OUT = CMA_OUT;    CPE_PN = [];
end

if CMA_appLMS
    [CPE_OUT CMA_MSE] = DspAlg.PolarizationDemux(CPE_OUT, ...
        constPoint,1,1,LMS_gain,LMS_taps,[],LMS_iter,1);
    CPE_OUT = CPE_OUT.*(sqrt(constPoint)-1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot results
cutoff = 16;
RTMOUT = TPE_OUT(1+cutoff:end-cutoff,:);
CMAOUT = CMA_OUT(1+cutoff:end-cutoff,:);
CPEOUT = CPE_OUT(1+cutoff:end-cutoff,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%