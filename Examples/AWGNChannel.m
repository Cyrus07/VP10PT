%   Bit Sequence Generation & BER calculation
%   v1.0, Lingchen Huang, 2015/3/16

AWGNChannel_Header;

Mod.mn = 4;
Mod.fs = 10e9;

Channel.SNR = 10;
SNR = 0:10;
for id_SNR = 1:length(SNR)
Channel.SNR = SNR(id_SNR);
BERTest = BERT_;

while BERTest.ErrCount < 200 || BERTest.BitCount < 2^14
    
    % generate PRBS sequence
    % PRBS.Input = [];
    PRBS.Processing();
    
    % modulate bit sequence to symbols
    Mod.Input = PRBS.Output;
    Mod.Processing();
    
    % transmit signal through channel
    Channel.Input = Mod.Output;
    Channel.Processing();
    
    % receiving and make hard decision
    Dec.Input = Channel.Output;
    Dec.hMod = Mod.h;
    Dec.Processing();
    
    % calculate bit error rate
    BERTest.Input = Dec.OutputBit;
    BERTest.RefBits = PRBS.Output;
    BERTest.Processing();
end
Log.BER(id_SNR) = BERTest.ErrRatio;
disp(['SNR = ',num2str(Channel.SNR)])
toc;
end