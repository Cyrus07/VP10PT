%   Bit Sequence Generation & BER calculation
%   v1.0, Lingchen Huang, 2015/3/16

FrameEle_Header;
nPol = 1;
FrameLen = 4 * 2^10;        % [syms] 
FrameOverlapLen = 2 * 2^10;    % [syms]

SNR = [3:9];
% SNR = 9;
for id_SNR = 1:length(SNR)
Channel.SNR = SNR(id_SNR);

while true
    % generate PRBS sequence
    % PRBS.Input = [];
    % PRBS.FECType = 'rs';
    Coder.FrameLen = FrameLen;
    Coder.FrameOverlapLen = FrameOverlapLen;
    Coder.mn = Mod.mn;
    PRBS.nSource = nPol;
    PRBS.BitseqLen = Coder.DemandBitsNumPerPol;
    PRBS.Processing();
    
    % modulate bit sequence to symbols
    Mod.mn = 4;
    Mod.Input = PRBS.Output;
    Mod.Processing();
    
    %
    Coder.Input = Mod.Output;
    Coder.Processing();
    
    %
    DAC.Input = Coder.Output;
    DAC.Processing();
    
    %
    Rectpulse.SymbolRate = 28e9;
    Rectpulse.SamplingRate = 28e9*1;
    Rectpulse.Input = DAC.Output;
    Rectpulse.Processing();
    
    %
    LPFTx.Bandwidth = 50e9;
    LPFTx.FilterShape = 'gaussian';
    LPFTx.FilterDomain = 'TD';
    LPFTx.Input = Rectpulse.Output;
    LPFTx.Processing();
    
    % transmit signal through channel
    Channel.FrameOverlapRatio = FrameOverlapLen/FrameLen;
    Channel.Input = LPFTx.Output;
    Channel.Processing();
    
    %
    LPFRx.Bandwidth = 50e9;
    LPFRx.FilterShape = 'gaussian';
    LPFRx.FilterDomain = 'TD';
    LPFRx.Input = Channel.Output;
    LPFRx.Processing();

    %
    Sampler.SamplingRate = 28e9;
    Sampler.SamplingPhase = 1;
    Sampler.Input = LPFRx.Output;
    Sampler.Processing();
    
    %
    DAC.Input = Sampler.Output;
    DAC.Processing();
    
    % De-overlap
    DeO.FrameOverlapRatio = FrameOverlapLen/FrameLen;
    DeO.Input = DAC.Output;
    DeO.Processing();
    
    % receiving and make hard decision
    % Dec.DispEVM = 1;
    Dec.Input = DeO.Output;
    Dec.hMod = Mod.h;
    Dec.Processing();
    
    % FEC
    FEC.nDecoders = nPol;
    FEC.FECType = PRBS.BinarySource{1}.FECType;
    FEC.Input = Dec.OutputBit;
    FEC.Processing();
    
    % calculate bit error rate
    % BERTest.DispIdx = 1;
    % BERTest.DispBER = 1;
    BERTest.RefBits = PRBS.MsgBuffer;
    BERTest.Input = FEC.Output;
    BERTest.Processing();
    
    % Termination condition
    if sum(BERTest.ErrCount) > 300 && sum(BERTest.BitCount) >= 2^16
        break;
    end
end

Log.BER(id_SNR) = sum(BERTest.ErrCount(3:end))/ sum(BERTest.BitCount(3:end));
disp(['SNR = ',num2str(Channel.SNR)])
toc;tic;
PRBS.Reset;
Coder.Reset;
DeO.Reset;
FEC.Reset;
BERTest.Reset;
end

figure(999);
semilogy(SNR+pow2db(1), Log.BER, 'r');
hold on;
mQAM = Bound.BER_mQAM;
mQAM.PlotType = 'EsNo-BER';
mQAM.ShowBER;