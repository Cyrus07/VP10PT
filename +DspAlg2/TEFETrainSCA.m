function [TrainingSequence, S2PSymbol, DiffModuInfo]  = TEFETrainSCA(SeqType, NumFFT)

NumGI = NumFFT / 8;

Seq1 = PNSequence(SeqType, NumFFT/2 ,1);
Seq2 = PNSequence(SeqType, NumFFT);
DiffModuInfo = Seq2(1:2:end)./Seq1;

S2PSymbol = zeros(NumFFT, 2);
S2PSymbol(1:2:end,1) = Seq1*sqrt(2);
S2PSymbol(:,2) = Seq2;
IDFTSequence = ifft(S2PSymbol);
CPSequence = [IDFTSequence(end-NumGI+1:end,:); IDFTSequence];

%% %%%%%%%%%%%%%   Parallel 2 Serial
TrainingSequence = reshape(CPSequence, 1, []);   
end