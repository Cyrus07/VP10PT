function SeqTD  = TEFETrainMinn(SeqType, NumBlock, NumFFT, Pattern)
% refer to A Robust Timing amd Frequency Synchronization for OFDM Systems
% Hlaing Minn, Vijay K. Bhargave, Khaled ben Letaief

Seq = PNSequence(SeqType, NumFFT);

% SeqTD = sqrt(Obj.M)*ifft(Seq, [], 1);
SeqTD = Seq;

SeqTD = (diag(Pattern) * repmat(SeqTD.', NumBlock, 1)).';

% add one more part to assist integer frequency offset estimate
Seq2 = PNSequence(SeqType, NumFFT*2);
SeqTD = [SeqTD, Seq2(1:2:end)];
end