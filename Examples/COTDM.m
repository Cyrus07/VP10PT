%%
continuousRunHeader_coherent;

% Carriers
linewidth = 0e3;
frequency = 0e9;

%% 
CTX.RandomNumberSeed = 1;
CTX.lenCoderSample = 2^14;
CTX.SamplingRate = 28e9;
CTX.BitPerSymbol = 2;

CTX.CoderType = 'TDM';
CTX.PreDistortionActive = 1;
CTX.ClippingRatio = 3;
CTX.ModulationPower = 1;
CTX.TrainingActvie = 0;

Rs = CTX.SamplingRate;
mn = 2^CTX.BitPerSymbol;
%%
OTX.RandomNumberSeed = 2;
OTX.SamplingRate = CTX.SamplingRate * 8;
OTX.Linewidth = linewidth;
% OTX.Bandwidth = 0.75 * Rs;
% OTX.Rz = 1;
% OTX.RzType = 'rz33';

%% 
ORX.RandomNumberSeedLD = 3;
ORX.Linewidth = linewidth;
ORX.CenterFrequency = OTX.CenterFrequency + frequency;
ORX.Bandwidth = 0.75 * Rs;
ORX.ADCSamplingRate = Rs * 2 ;
ORX.ADCSamplingPhase = 2;

%% 
LOOP.Active = 0;
LOOP.DispersionParam = 16e-6;
LOOP.Length = 10e3;
LOOP.PMDtype = 'full';
LOOP.PMDparam = 0.05e-12/sqrt(1e3);
LOOP.CD;

%%
SetOSNR.OSNR = 20;

%%
EDFA.WorkingMode = 'APC';
EDFA.NoiseFigure = Inf;
EDFA.Power = -10;

%% 
while ORX.RunCount <5
sym = CTX.Output;
tx = OTX.Output(sym,Rs);
nx = SetOSNR.Output(tx,Rs);
fx = EDFA.Output(nx);
fx = LOOP.Output(fx);
rx = ORX.Output(fx);
end
%% 
% optPowerMeter(tx,1);
% SCOPE.Output(tx)

%% 
DSPIN = ORX.recDataVec.Buffer;
% scatterplot(DSPIN(1:2:end,1));
% scatterplot(DSPIN(2:2:end,2));
sps = 2;

%% CD compensation 
cd = LOOP.CD * LOOP.Active;
fc = tx.fc;
fs = Rs*sps;
[DCFOUT,H] = DspAlg.FrequencyDCF(DSPIN,cd,fc,fs,512,'ideal');

%% Timing recovery
[TPEOUT,tpn] = DspAlg.FeedbackTPE(DCFOUT,mn,sps,16,1e-4,'gardner','linear');
% [TPEOUT,tpn] = DspAlg.FeedbackTPE(DCFOUT,mn,sps,64,1e-2,'godard','linear');
% [TPEOUT,tpn] = DspAlg.FeedforwardTPE(DCFOUT,mn,sps,512,1,'lee','linear',1);
sps = 1;

%% Polarization 
% multi-stage
mu    = [1e-4 1e-5 1e-6];
ntaps = [13 13 13];
errid = [1 1 3];
iterCMA = [1 1 0];
[CMAOUT,mse] = DspAlg.PolarizationDemux(TPEOUT,mn,sps,1,mu,ntaps,errid,iterCMA,0);

%% Frequency
% [FOCOUT,df] = DspAlg.FeedforwardFOC(CMAOUT,Rs,frequency);
[FOCOUT,df] = DspAlg.FeedforwardFOC(CMAOUT,Rs);

%% CPE
bs = 21;
appML = 0;
iterML = 0;
% mu = 0.01;
% [CPEOUT,pn] = DspAlg.FeedforwardCPE(FOCOUT,mn,bs,'block',appML,iterML);
% [CPEOUT,pn] = DspAlg.FeedforwardCPE(FOCOUT,mn,bs,'slide',appML,iterML);
[CPEOUT,pn] = DspAlg.FeedforwardCPE(FOCOUT,mn,bs,'bps',appML,iterML);
% [CPEOUT,pn] = DspAlg.FeedbackCPE(FOCOUT,mn,mu,[0,0],appML,bs,iterML);
% [CPEOUT,pn] = cpe_pll_2nd(FOCOUT,mn,0.012,0.012,appML,bs,iterML);

%% LMS
% mu = 1e-5;
% ntaps = 101;
% errid = 0;
% iterCMA = 10;
% stage = 2;
% [CPEOUT,mse] = polar_demux(CPEOUT,mn,sps,mu,ntaps,stage,errid,iterCMA);

%% Test
% bitRef = ETX.Coder.SymReference;
% [er,ec] = matlab_bert(CPEOUT,mn,bitRef,'gray')
% [er,ec] = matlab_bert(CPEOUT,mn,bitRef,'binary')
% [er,ec] = matlab_bert(CPEOUT,mn,bitRef,'diff')
BERTest.Method = 'Gray';
BERTest.Output(CPEOUT, CTX.RefSymbol.Buffer, mn);
pause;
%% Figures
% scatterplot(DCFOUT(:,1))
% scatterplot(DCFOUT(:,2))

% scatterplot(TPEOUT(:,1))
% scatterplot(TPEOUT(:,2))

% scatterplot(CMAOUT(:,1))
% scatterplot(CMAOUT(:,2))

% scatterplot(FOCOUT(:,1))
% scatterplot(FOCOUT(:,2))

% scatterplot(CPEOUT(:,1))
% scatterplot(CPEOUT(:,2))

% T_BER_mQAM(SetOSNR.OSNR,mn(1),Rs)