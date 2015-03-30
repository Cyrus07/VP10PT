function matcs = CETrainDD(PolarDiversity, ChannelEst, SeqType, NumBlock, NumFFT)

Seq = PNSequence(SeqType, NumFFT/2);
Seq(1) = 0;
switch ChannelEst
    case 'Diag'
        J = eye(PolarDiversity);
    case 'Hadamard'
        J = PNSequence('Walsh', PolarDiversity, PolarDiversity);
end
for pol = 1:PolarDiversity
    matcs{pol} = Seq * J(pol,:);
    matcs{pol} = repmat(matcs{pol}, 1, NumBlock);
end

end