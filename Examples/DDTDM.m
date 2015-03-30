%%
continuousRunHeader_directdetect;

% Carriers
linewidth = 0e3;
frequency = 0e9;

%% 
CTX.RandomNumberSeed = 1;
CTX.lenCoderSample = 2^14;
CTX.SamplingRate = 10e9;
CTX.BitPerSymbol = 1;

CTX.CoderType = 'TDM';
CTX.OptModType = 'SDMz';
CTX.ModulationPower = 1;
CTX.TrainingActvie = 0;

Rs = CTX.SamplingRate;
mn = 2^CTX.BitPerSymbol;
%%
OTX.RandomNumberSeed = 2;
OTX.SamplingRate = CTX.SamplingRate * 16;
OTX.Linewidth = linewidth;
OTX.TxType = 'SDMz';
% OTX.Bandwidth = 0.75 * Rs;
% OTX.Rz = 1;
% OTX.RzType = 'rz33';

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
EDFA.NoiseFigure = Inf;
EDFA.Power = -20;

%% 
while ORX.RunCount <5
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
DSPIN = ORX.recDataVec.Buffer;
% scatterplot(DSPIN(1:2:end,1));
% scatterplot(DSPIN(2:2:end,2));
sps = 2;

%% Timing recovery
[TPEOUT,tpn] = DspAlg.FeedbackTPE(DSPIN,mn,sps,16,1e-4,'gardner','linear');
% [TPEOUT,tpn] = DspAlg.FeedbackTPE(DCFOUT,mn,sps,64,1e-2,'godard','linear');
% [TPEOUT,tpn] = DspAlg.FeedforwardTPE(DCFOUT,mn,sps,512,1,'lee','linear',1);
sps = 1;

%% Test
% bitRef = ETX.Coder.SymReference;
% [er,ec] = matlab_bert(CPEOUT,mn,bitRef,'gray')
% [er,ec] = matlab_bert(CPEOUT,mn,bitRef,'binary')
% [er,ec] = matlab_bert(CPEOUT,mn,bitRef,'diff')
BERTest.Method = 'Gray';
BERTest.Output(TPEOUT, CTX.RefSymbol.Buffer, mn);
pause;
%% Figures
% scatterplot(TPEOUT(:,1))
% scatterplot(TPEOUT(:,2))

% T_BER_mQAM(SetOSNR.OSNR,mn(1),Rs)