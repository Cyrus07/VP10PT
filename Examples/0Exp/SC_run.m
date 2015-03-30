%% Single Run Test Script
% multi carrier coherent optical link without DSP


%%
W_HEADER;
ETX.CoderType = 'TDM';
ETX.PreDistortion=0;
ETX.RandomNumberSeed = 1;
%% 
linewidth = 1e5;
OTX.Linewidth = linewidth;
ORX.Linewidth = linewidth;

%% 
frequency = 0e9;
OTX.CenterFrequency = Default.CenterFrequency;
ORX.CenterFrequency = Default.CenterFrequency + frequency;

%% 
ORX.Bandwidth = 2 * Rs;

%% Write Data

rf = ETX.Output;

BitNum = length(rf{1}{1}.E);
Marker1 = zeros(BitNum,1);
Marker1(1:2:end) = 1;
Marker2 = zeros(BitNum,1);
CH1.Data = rf{1}{1}.E;
CH1.Mk1 = Marker1;
CH1.Mk2 = Marker2;
CH1.WFMName = 'WFM1R';
CH2.Data = rf{1}{5}.E;
CH2.Mk1 = Marker1;
CH2.Mk2 = Marker2;
CH2.WFMName = 'WFM1I';
% ExportToDAC(CH1,CH2);


%% Read Data
sps = 2;
for k = 1:20
DSPIN = ImportFromADC(Rs, sps);
save(['2QPSK_' num2str(k) '.mat'],'DSPIN');
end
for id_run = 1:1
% load(['D:\HLc\080313\ExpData-1Loop\Aug-16th-ExpData-1Loop-' num2str(id_run) '.mat']);sps = 4;
% load(['D:\HLc\080313\ExpData-5Loop\Aug-16th-ExpData-5Loop-' num2str(id_run) '.mat']);sps = 4;
% load(['D:\HLc\080313\ExpData-b2b\Aug-13th-ExpData-' num2str(id_run) '.mat']);sps = 4;
sps = 2;
DSPIN = ImportFromADC(Rs, sps);
save('DATA2.mat','DSPIN');
% load('DATA.mat');

% load(['Aug-16th-ExpData-1Loop-' num2str(id_run) '.mat']);sps = 4;
% DSPIN = conj(DSPIN);
[DSPIN,theta] = DspAlg.Orthogonal(DSPIN);
%% Filter
% 
% bw = 0.75 * Rs;
% Fs = Rs * sps;
% Nsamp = size(DSPIN,1);
% f = (-Nsamp/2 : Nsamp/2-1)/Nsamp*Fs;
% Hf = ifftshift(myfilter('supergauss',f,bw,2));
% % Hf = ifftshift(myfilter('bessel5',f,bw));
% % Hf = ifftshift(myfilter('ideal',f,bw));
% DSPIN = ifft( Hf * ones(1,size(DSPIN,2)) .* fft(DSPIN));

%% CD compensation 
% DSPIN(:,2) = DSPIN;
DCFOUT = DSPIN;
% scatterplot(DCFOUT(:,1))
% scatterplot(DCFOUT(:,2))

%% Timing recovery

% [TPEOUT,tpn] = DspAlg.FeedbackTPE(DCFOUT,mn,sps,4,1e-4,'gardner','linear');
% [TPEOUT,tpn] = DspAlg.FeedbackTPE(DCFOUT,mn,sps,1e-4,'gardner','parabolic');
[TPEOUT,tpn] = DspAlg.FeedforwardTPE(DCFOUT,mn,sps,512,1,'lee','linear',1);


%% Polarization 
sps = 1;
% multi-stage
mu    = [1e-4 1e-5 1e-6];
ntaps = [13 13 13];
errid = [1 1 3];
iterCMA = [0 30 0];
[CMAOUTa,mse] = DspAlg.PolarizationDemux(TPEOUT,mn,sps,1,mu,ntaps,errid,iterCMA,0);
% scatterplot(CMAOUTa(:,1))
% scatterplot(CMAOUT(:,2))
%% Frequency
[FOCOUTa,df] = DspAlg.FeedforwardFOC(CMAOUTa,Rs);
% FOCOUT = CMAOUT;
% scatterplot(FOCOUTa(:,1))
% scatterplot(FOCOUT(:,2))
%% CPE

bs = 21;
appML = 0;
iterML = 0;
% mu = 0.01;
[CPEOUTa,pn] = DspAlg.FeedforwardCPE(FOCOUTa,mn,bs,'block',appML,iterML);
% [CPEOUT,pn] = DspAlg.FeedforwardCPE(FOCOUT,mn,bs,'slide',appML,iterML);
% [CPEOUT,pn] = DspAlg.FeedforwardCPE(FOCOUT,mn,bs,'bps',appML,iterML);
scatterplot(CPEOUTa(:,1))
% scatterplot(CPEOUTa(:,2))

%% Test
csRef = ETX.Coder.SymReference;
csRef{1} = csRef{1}.';
csRef{2} = csRef{1};
h = modem.qamdemod('M', mn);
h.OutputType = 'int';
symRef{1} = h.demodulate(csRef{1});
symRef{2} = symRef{1};

%% De Couple
for pol = 1:size(CPEOUTa,2)
[~, tmp] = matlab_demod(CPEOUTa(:,pol),mn,'gray');
csa(:,pol) = matlab_mod(tmp, mn, 'gray');
csb(:,pol) = CPEOUTa(:,pol) - csa(:,pol);
end

[BERa, EVMa, BERDa] = bertEXP(CPEOUTa, symRef, csRef, mn);

%% Polarization 

% multi-stage
mu    = [1e-4 1e-5 1e-6];
ntaps = [13 13 13];
errid = [1 3 3];
iterCMA = [1 100 0];
[CMAOUTb,mse] = DspAlg.PolarizationDemux(csb,mn,sps,1,mu,ntaps,errid,iterCMA,0);
% scatterplot(CMAOUTb(:,1))
% scatterplot(CMAOUTb(:,2))
%% Frequency
[FOCOUTb,df] = DspAlg.FeedforwardFOC(CMAOUTb,Rs);
% scatterplot(FOCOUTb(:,1))
% scatterplot(FOCOUTb(:,2))
%% CPE

bs = 21;
appML = 0;
iterML = 0;
[CPEOUTb,pn] = DspAlg.FeedforwardCPE(FOCOUTb,mn,bs,'bps',appML,iterML);
scatterplot(CPEOUTb(:,1))
% scatterplot(CPEOUTb(:,2))
%%
[BERb, EVMb, BERDb] = bertEXP(CPEOUTb, symRef, csRef, mn);
%% Limit
% T_BER_mQAM(SetOSNR.OSNR,mn(1),Rs)
end