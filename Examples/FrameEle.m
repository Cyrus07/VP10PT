%   Bit Sequence Generation & BER calculation
%   v1.0, Lingchen Huang, 2015/4/1

FrameEle_Header;

nPol = 1;
BitPerSymbol = 2;
FrameLen = 4 * 2^10;            % [syms] 
FrameOverlapLen = 2 * 2^10;     % [syms]

Tx.FrameLen = FrameLen;
Tx.FrameOverlapLen = FrameOverlapLen;
Tx.mn = BitPerSymbol^2;
Tx.nSource = nPol;
Init(Tx);

Channel.FrameOverlapRatio = FrameOverlapLen / FrameLen;
Channel.SymbolRate = 28e9;
Channel.TxSamplingRate = 28e9 * 1;
Channel.TxBandwidth = 50e9;
Channel.TxFilterShape = 'Gaussian';
Channel.TxFilterDomain = 'TD';
Channel.RxBandwidth = 50e9;
Channel.RxFilterShape = 'Gaussian';
Channel.RxFilterDomain = 'TD';
Channel.RxSamplingRate = 28e9 * 1;
Channel.SamplingPhase = 1;
Init(Channel);

SNR = [3:9];
% SNR = 9;
for id_SNR = 1:length(SNR)
Channel.Ch.SNR = SNR(id_SNR);

while true
    Tx.Processing();
    
    Channel.Input = Tx.Output;
    Channel.Processing();
    
    % receiving and make hard decision
    % Dec.DispEVM = 1;
    Dec.Input = Channel.Output;
    Dec.hMod = Tx.Mod.h;
    Dec.Processing();
    
    % FEC
    FEC.nDecoders = nPol;
    FEC.FECType = Tx.PRBS.BinarySource{1}.FECType;
    FEC.Input = Dec.OutputBit;
    FEC.Processing();
    
    % calculate bit error rate
    % BERTest.DispIdx = 1;
    % BERTest.DispBER = 1;
    BERTest.RefBits = Tx.PRBS.MsgBuffer;
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
Tx.Reset;
Channel.Reset;
FEC.Reset;
BERTest.Reset;
end

figure(999);
semilogy(SNR+pow2db(1), Log.BER, 'r');
hold on;
mQAM = Bound.BER_mQAM;
mQAM.PlotType = 'EsNo-BER';
mQAM.ShowBER;