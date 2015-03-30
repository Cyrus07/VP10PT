%   Copyright: (c)2011 (dawei.zju@gmail.com)
%   Last modification 2014, Lingchen

clear all
disp('=======================================')
disp(datestr(now))
% disp('---------------------------------------')
tic;

% Reinitialize the global random number stream 
% using a seed based on the current time. 
s = RandStream('mt19937ar','Seed','shuffle');
RandStream.setGlobalStream(s);
clear s;

CTX     = singleRun.CoderTxCoh;
OTX     = singleRun.OpticalTxCoh;
ORX     = singleRun.OpticalRxCoh;
SetOSNR = singleRun.SetOpticalSNR;
EDFA    = singleRun.OpticalAmplifier;
LOOP    = singleRun.FiberLoop;
FIBER   = singleRun.OpticalFiber;

SCOPE   = SignalAnalyzer;
BERTest = BERT;
