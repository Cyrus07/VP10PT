%   Bit Sequence Generation & BER calculation
%   v1.0, Lingchen Huang, 2015/3/16

OverlapOFDM_Header;
FrameLen = 16 * 288;        % [syms] 
FrameOverlapLen = 4 * 288;    % [syms]

% PRBS.FECType = 'rs';
Mod.mn = 4;
Mod.fs = 10e9;

% Coder.
Coder.FrameLen = FrameLen;
Coder.FrameOverlapLen = FrameOverlapLen;
Coder.mn = Mod.mn;
PRBS.BitseqLen = Coder.DemandBitsNumPerPol;


Channel.FrameOverlapLen = FrameOverlapLen;

DeO.FrameOverlapRatio = FrameOverlapLen/FrameLen;


SNR = [3:10];
% SNR = 99;
for id_SNR = 1:length(SNR)
Channel.SNR = SNR(id_SNR);
BERTest = BERTAsync;
% BERTest.DispIdx = 1;
% BERTest.DispBER = 1;
% Dec.DispEVM = 1;

while sum(BERTest.ErrCount) < 200 || sum(BERTest.BitCount) < 2^16
    
    % generate PRBS sequence
    % PRBS.Input = [];
    PRBS.Processing();
    
    % modulate bit sequence to symbols
    Mod.Input = PRBS.Output;
    Mod.Processing();
    
    Coder.Input{1} = Mod.Output;
    Coder.Processing();
    
    % transmit signal through channel
    Channel.Input = Coder.Output{1};
    Channel.Processing();
    
    % De-overlap
    DeO.Input = Channel.Output;
    DeO.Processing();
    
    DeCoder.Input = DeO.Output;
    DeCoder.OFDM = Coder.OFDM;
    DeCoder.PilotSequence = Coder.PilotSequence;
    DeCoder.Processing();
    
    % receiving and make hard decision
    Dec.Input = DeCoder.Data;
    Dec.hMod = Mod.h;
    Dec.Processing();
    
    % FEC
    FEC.FECType = PRBS.FECType;
    FEC.Input = Dec.OutputBit;
    FEC.Processing();
    
    % calculate bit error rate
    BERTest.RefBits = Output(PRBS.MsgBuffer);
    BERTest.Input = FEC.Output;
    BERTest.Processing();
end
Log.BER(id_SNR) = sum(BERTest.ErrCount(3:end))/ sum(BERTest.BitCount(3:end));
disp(['SNR = ',num2str(Channel.SNR)])
toc;tic;
end

figure(999);
semilogy(SNR, Log.BER, 'r');
hold on;
mQAM = Bound.BER_mQAM;
mQAM.PlotType = 'EsNo-BER';
mQAM.ShowBER;