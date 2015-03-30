%   v1.0, Lingchen Huang, 2015/3/16

clear all
disp('=======================================')
disp(datestr(now))
disp('Start simulation...')
tic

% Reinitialize the global random number stream 
% using a seed based on the current time. 
s = RandStream('mt19937ar','Seed','shuffle');
RandStream.setGlobalStream(s);
clear s;

PRBS        = SourceBinarys;
Mod         = ModulateQAM;
Coder       = CoderTDM;
DAC         = EleQuantizer;
Rectpulse   = EleRectPulse;
LPFTx       = EleLPF;
Channel     = ChEleAWGN;
LPFRx       = EleLPF;
Sampler     = EleSampler;
ADC         = EleQuantizer;
DeO         = DeOverlap;
Dec         = Decision_;
FEC         = FECDecoders;
BERTest     = BERTAsync;