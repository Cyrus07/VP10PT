%% Single Run Test Script
% multi carrier coherent optical link without DSP


%%
W_HEADER;
ETX.CoderType = 'OFDM';
ETX.NumFFT = 256;
ETX.NumSubCarr = 192;
ETX.NumPilot = 10;
ETX.NumGI = 1 / 8 * ETX.NumFFT;
ETX.RandomNumberSeed = 1;
%% 
frequency = 0e9;

%% 
ETX.PreDistortion = 0;
ETX.TimeDelay = 0;
ETX.TimingFreqEst = 'Minn_A';     % 'SCA', 'Minn', 'Minn_A'
ETX.ChannelEst = 'Diag';        % 'Diag', 'Hadamard'
ETX.CEBlock = 20;
ETX.ClippingRatio = 2.7;

FIBER.Length = 0e3;

%% Write Data
rf = ETX.Output;
% ExportToDAC(rf);

%% Read Data
% for k = 1:20
% [DSPIN sps] = ImportFromADC;
% save(['Aug-16th-ExpData-5Loop-' num2str(k) '.mat'],'DSPIN');
% end
for id_run = 1:20
% load(['D:\HLc\080313\ExpData-1Loop\Aug-16th-ExpData-1Loop-' num2str(id_run) '.mat']);sps = 4;
load(['D:\HLc\080313\ExpData-5Loop\Aug-16th-ExpData-5Loop-' num2str(id_run) '.mat']);sps = 4;
% load(['D:\HLc\080313\ExpData-b2b\Aug-13th-ExpData-' num2str(id_run) '.mat']);sps = 4;
% [DSPIN sps] = ImportFromADC;
% load(['Aug-16th-ExpData-1Loop-' num2str(id_run) '.mat']);sps = 4;
DSPIN = conj(DSPIN);
% DSPIN = -DSPIN;
%% Filtering
ORX.Bandwidth = 0.5 * Rs;
Active = 1;
ElectricalLPF = Bessel5Filt('Bandwidth', ORX.Bandwidth, 'Active', Active);
V = ElectricalSignal('E',DSPIN.','fs',Rs*sps);
y = ElectricalLPF.filter(V);
DSPIN = y.E.';

%% Timing, Frequency, CD compensation
TFE = ETX.Coder.TimingFreqEst;
Seq = ETX.Coder.TFESeqType;
l = ETX.Coder.TFEBlock;
m = ETX.Coder.TFEFFT;
p = ETX.Coder.TFEPattern;
th = 0.5;
cd = FIBER.Length * FIBER.DispersionParam;
timing = ETX.Coder.TimeDelay;
[TEFEOUT te fe]= DspAlg2.TimingFreqEstimator(DSPIN, TFE, Seq, l, m, ...
    p, sps, th, cd, timing, frequency);
clear TFE Seq l m p th cd timing;

%% CPE TD
Active = 0;
if Active
    bw = 25e6;
    flen = 2^11;
    [CPEOUT pn_hat] = DspAlg2.PhaseEstimatorTimeDomain(TEFEOUT, Default.SymbolRate*sps, bw, flen);
%     pn = (OTX.Laser.PhaseNoise - ORX.Laser.PhaseNoise).';
%     pn2 = pn(1:Default.SamplesPerSymbol/sps:end,1);
%     pn2 = pn2(end-length(pn_hat)+1:end,1);
%     plot(pn_hat(:,1),'r'); hold on;
%     plot(pn2,'k'); plot(pn_hat(:,1) - pn2,'g');
%     msepn = var(pn_hat(:,1) - pn2);
%     close;
else
    CPEOUT = TEFEOUT;
end
clear bw flen pn2 pn Active;
%% Timing Phase Estimate and Re-Sampling
Seq = ETX.Coder.TrainTimingFreqEst;
[TPEOUT,tpn] = DspAlg2.FeedforwardTPE(CPEOUT,sps,Seq,te,'JWang','parabolic');
% 
% TPEOUT = CPEOUT(te:end,:);
% % TPEOUT = (TPEOUT(1:sps:end,:)+TPEOUT(3:sps:end,:))/2;
% TPEOUT = TPEOUT(2:sps:end,:);
% TPEOUT = TPEOUT(length(Seq{1})+1:end,:);
% 
TPEOUT = TPEOUT(round(ETX.Coder.NumGI/2)+1:end,:);
%% CE
cetype = 'ISTA'; % 'ISTA', 'Lms', 'ISFA'
traintype = ETX.ChannelEst;
seq = ETX.Coder.CESeqType;
pol = Default.PolarDiversity;
nfft = ETX.Coder.CEFFT;
ngi = ETX.Coder.NumGI;
nblock = ETX.Coder.CEBlock;

x = TPEOUT(1:nblock*pol*(nfft+ngi),:);
CEOUT = TPEOUT(1+nblock*pol*(nfft+ngi):end,:);

ce_reverse = DspAlg2.ChannelEstimator(x, cetype, traintype, seq, pol, nblock, nfft, ngi);
clear type seq pol nblock nfft

%% CPE FD
pol = Default.PolarDiversity;
nfft = ETX.Coder.NumFFT;
nblock = ETX.Coder.NumBlock;
ngi = ETX.Coder.NumGI;
IndPilot = ETX.Coder.IndPilot;
IndSubCarr = ETX.Coder.IndSubCarr;

[CPE2OUT, pn] = DspAlg2.PhaseEstimatorFreqDomian(CEOUT, pol, nblock, nfft, ngi, ce_reverse, IndPilot, IndSubCarr);
clear pol nfft nblock ngi IndPilot IndSubCarr

%% Normalize
mn = ETX.Coder.DoBitloading;
ref = ETX.Coder.SymReference;
map = ETX.MapMethod;

for n = 1:Default.PolarDiversity
    for k = 1:size(CPE2OUT{n},1)
        cs{n}(k,:) = DspAlg.Normalize(CPE2OUT{n}(k,:), mn(k));
        cs{n}(k,:) = DspAlg2.PhaseOffsetEstimate(cs{n}(k,:));
    end
%     cs{n} = DspAlg.Normalize(CPE2OUT{n}, mn(1));
    [ber(n) evm(:,n)] = DspAlg2.bertMC(cs{n}, ref{n}, mn(1), map);
    ber
    mean(evm)
%     scatterplot(reshape(cs{n},1,[]));
%     Hist2(reshape(cs{n},1,[]));
end
ber_run(id_run) = ber;

end
ber_run
%% Limit
% osnr = 10:0.1:20;
% semilogy(osnr,T_BER_mQAM(osnr,mn(1),Rs))
% T_BER_mQAM(SetOSNR.OSNR,mn(1),Rs)
for k = 1:16:192
    scatterplot(cs{1}(k,:))
end