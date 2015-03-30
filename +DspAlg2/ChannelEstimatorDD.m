function ce_reverse = ChannelEstimatorDD(x, cetype, trainingtype, seqtype, pol, nblock, nfft, ngi)

Seq = PNSequence(seqtype, nfft/2);
Seq(1) = 0;
ind = 2:nfft/2;
Seq(nfft+2-ind,:) = conj(Seq(ind));
switch trainingtype
    case 'Diag'
        J = eye(pol);
    case 'Hadamard'
        J = PNSequence('Walsh', pol, pol);
    case 0
        for k = 1:nfft; ce_reverse(k,:,:) = eye(pol); end
        return;
    otherwise
end

switch cetype
    case 'ISTA'
        ce_reverse = DspAlg2.CEDDISTA(x, pol, nfft, ngi, nblock, Seq, J);
    case 'Lms'
        ce_reverse = DspAlg2.CELms(x, pol, nfft, ngi, nblock, Seq, J);
    case 'ISFA'
        ce_reverse = DspAlg2.CEDDISTA(x, pol, nfft, ngi, nblock, Seq, J);
        ce_reverse = DspAlg2.CEISFA(ce_reverse, taps, nfft);
end

end