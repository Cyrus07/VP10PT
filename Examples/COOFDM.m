%%
continuousRunHeader_coherent;

% Carriers
linewidth = 0e3;
frequency = 0e9;

%% 
CTX.RandomNumberSeed = 1;
CTX.lenCoderSample = 2^14;
CTX.SamplingRate = 12e9;
CTX.BitPerSymbol = 2;
CTX.PolarDiversity = 1;

CTX.CoderType = 'OFDM';
CTX.NumFFT = 256;
CTX.NumGI = 256/8;
CTX.NumSubCarr = 200;
CTX.NumPilot = 10;

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
OTX.SamplingRate = CTX.SamplingRate * 8;
OTX.Linewidth = linewidth;
OTX.Bandwidth = 0.5 * Rs;

%% 
ORX.RandomNumberSeedLD = 3;
ORX.Linewidth = linewidth;
ORX.CenterFrequency = OTX.CenterFrequency + frequency;
ORX.Bandwidth = 0.5 * Rs;
ORX.ADCSamplingRate = 2 * Rs ;
ORX.ADCSamplingPhase = 2;

%%
LOOP.Active = 0;
LOOP.DispersionParam = 16e-6;
LOOP.Length = 10e3;
LOOP.PMDtype = 'full';
LOOP.PMDparam = 0.05e-12/sqrt(1e3);
LOOP.CD;

%%
SetOSNR.Active = 1;
SetOSNR.OSNR = 8;

%%
EDFA.WorkingMode = 'APC';
EDFA.NoiseFigure = Inf;
EDFA.Power = -10;

%% 
while ORX.RunCount <5
sym = CTX.Output;
tx = OTX.Output(sym, Rs);
nx = SetOSNR.Output(tx);
fx = EDFA.Output(nx);
fx = LOOP.Output(fx);
rx = ORX.Output(fx);
end
%% 
% optPowerMeter(tx,1);
% SCOPE.Output(tx)

%%
DSPIN = ORX.recDataVec.Buffer(:,1:CTX.PolarDiversity);
sps = ORX.ADCSamplingRate / Rs;

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

%%   CD Compensation
Seq = PNSequence(CTX.Training.TFESeqType, CTX.Training.TFEFFT);
Seq = reshape((diag(CTX.Training.TFEPattern) * repmat(Seq.', CTX.Training.TFEBlock, 1)).',1,[]);

CDEActive = 0;
if CDEActive
    cd = DspAlg2.TimedomainCDE(x,Seq,sps);
else
    cd = LOOP.CD * LOOP.Active;
end
[DCFOUT ,H] = DspAlg.FrequencyDCF(TEFEOUT,cd,fx.fc, sps*Rs, 512, 'ideal');

%% Timing Phase Estimate and Re-Sampling
% estMeth = 'JWang';
% [TPEOUT,tpn] = DspAlg.FeedforwardTPE(DCFOUT,mn,sps,128,1.2,'lee','linear',1);
[TPEOUT,tpn] = DspAlg2.FeedforwardTPE(DCFOUT,sps,Seq,te);
Len = (CTX.Training.TFEBlock+1) * CTX.Training.TFEFFT * CTX.Training.TFETraningActive;
TPEOUT = TPEOUT(Len+1:end,:);

%% CE
cetype = 'ISTA'; % 'ISTA', 'Lms', 'ISFA'
[CEOUT, ce] = DspAlg2.ChannelEstimator(TPEOUT, cetype, CTX.Training, CTX.Coder);

%% CPE FD
[CPE2OUT, pn] = DspAlg2.PhaseEstimatorFreqDomian(CEOUT, CTX.Coder);

%% Normalize
BERTest.Method = 'Gray';
BERTest.Output(CPE2OUT, CTX.RefSymbol.Buffer, mn);
pause;
%% Limit
% scatterplot(CPE2OUT(:,1))
% Hist2(CPE2OUT(:,1))
% T_BER_mQAM(SetOSNR.OSNR,mn(1),Rs)