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
Tx.nPol = nPol;
Init(Tx);

Channel.nPol = nPol;
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
Channel.ChBufLen = FrameLen * 1;
Init(Channel);

Rx.nPol = nPol;
Rx.FECType = Tx.PRBS.BinarySource{1}.FECType;
Rx.hMod = Tx.Mod.h;
Init(Rx);

SNR = [3:9];
% SNR = 9;
for id_SNR = 1:length(SNR)
Channel.Ch.SNR = SNR(id_SNR);

while true
    
    Processing(Tx);
    
    Channel.Input = Tx.Output;
    Processing(Channel);
    
    Rx.RefMsg = Tx.PRBS.RefMsg;
    Rx.Input = Channel.Output;
    Processing(Rx);
    
    if ~isempty(Rx.BER)
        break;
    end
end

Log.BER(id_SNR) = Rx.BER;
disp(['SNR = ',num2str(Channel.SNR)])
toc;tic;
Reset(Tx);
Reset(Channel);
Reset(Rx);
end

figure(999);
semilogy(SNR+pow2db(1), Log.BER, 'r');
hold on;
mQAM = Bound.BER_mQAM;
mQAM.PlotType = 'EsNo-BER';
mQAM.ShowBER;