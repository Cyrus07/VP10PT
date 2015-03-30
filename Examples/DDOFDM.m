%%
continuousRunHeader_directdetect;

% Carriers
linewidth = 0e3;
frequency = 0e9;

%% 
CTX.RandomNumberSeed = 1;
CTX.lenCoderSample = 2^14;
CTX.SamplingRate = 12e9;
CTX.BitPerSymbol = 2;

CTX.CoderType = 'OFDM';
CTX.Option = 'DD-DSB';
CTX.OptModType = 'SDMz';
CTX.NumFFT = 256;
CTX.NumGI = 256/8;
CTX.NumSubCarr = 100;
CTX.NumPilot = 0;

CTX.PreDistortionActive = 1;
CTX.ClippingRatio = 3;
CTX.ModulationPower = 0.1;
CTX.TimeDelay = 10E2;
CTX.TFETraningActive = 1;
CTX.TimingFreqEst = 'Minn';     % 'SCA', 'Minn', false
CTX.CETraningActive = 1;
CTX.ChannelEst = 'Diag';        % 'Diag', 'Hadamard', false
CTX.CEBlock = 10;

Rs = CTX.SamplingRate;
mn = 2^CTX.BitPerSymbol;
%% 
OTX.RandomNumberSeed = 2;
OTX.SamplingRate = CTX.SamplingRate * 16;
OTX.Linewidth = linewidth;
OTX.TxType = 'SDMz';
OTX.Bandwidth = 0.5 * Rs;

%% 
ORX.Bandwidth = 0.75 * Rs;
ORX.ADCSamplingRate = Rs * 2 ;
ORX.ADCSamplingPhase = 4;

%%
FIBER.Active = 0;
FIBER.DispersionParam = 16e-6;
FIBER.Length = 10e3;
FIBER.PMDtype = 'full';
FIBER.PMDparam = 0.05e-12/sqrt(1e3);
FIBER.CD;

%%
EDFA.WorkingMode = 'APC';
EDFA.NoiseFigure = 5;
EDFA.Power = -10;

%% 
while ORX.RunCount <10
sym = CTX.Output;
tx = OTX.Output(sym,Rs);
fx = EDFA.Output(tx);
fx = FIBER.Output(fx);
rx = ORX.Output(fx);
end
%% 
% optPowerMeter(tx,1);
% SCOPE.Output(tx)

%%
DSPIN = ORX.recDataVec.Buffer(:,1);
sps = 2;

%% CPE TD
Active = 0;
if Active
    bw = 25e6;
    flen = 2^11;
    [CPEOUT pn_hat] = DspAlg2.PhaseEstimatorTimeDomain(DSPIN, CTX.SamplingRate*sps, bw, flen);
else
    CPEOUT = DSPIN;
end

%% Timing, Frequency
th = 0.2;
[TEFEOUT, te, fe]= DspAlg2.TimingFreqEstimator(CPEOUT, CTX.Training, frequency/sps/Rs, sps, th);
terror = te - CTX.Training.TimeDelay*sps - 1;
ferror = fe*Rs*sps + frequency;

%% Timing Phase Estimate and Re-Sampling
Seq = PNSequence(CTX.Training.TFESeqType, CTX.Training.TFEFFT);
Seq = reshape((diag(CTX.Training.TFEPattern) * repmat(Seq.', CTX.Training.TFEBlock, 1)).',1,[]);
% estMeth = 'JWang';
% [TPEOUT,tpn] = DspAlg.FeedforwardTPE(DCFOUT,mn,sps,128,1.2,'lee','linear',1);
[TPEOUT,tpn] = DspAlg2.FeedforwardTPE(TEFEOUT,sps,Seq,te);
Len = (CTX.Training.TFEBlock+1) * CTX.Training.TFEFFT * CTX.Training.TFETraningActive;
TPEOUT = TPEOUT(Len+1:end,:);

%% CE
cetype = 'ISTA'; % 'ISTA', 'Lms', 'ISFA'
[CEOUT, ce] = DspAlg2.ChannelEstimator(TPEOUT, cetype, CTX.Training, CTX.Coder);
CEOUT = CEOUT(CTX.Coder.IndSubCarr,:);
%% Normalize
BERTest.Method = 'Gray';
BERTest.Output(CEOUT(:), CTX.RefSymbol.Buffer, mn);
pause;
%% Limit
% scatterplot(CEOUT(:,1))
% Hist2(CPE2OUT(:,1))
% T_BER_mQAM(SetOSNR.OSNR,mn(1),Rs)