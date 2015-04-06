InitSim;

obj = CohOptB2B;
Init(obj);
Log.SNR = [3:9];

% Log.SNR = 9;
for id_SNR = 1:length(Log.SNR)
    obj.Channel.Ch.SNR = Log.SNR(id_SNR);
    Processing(obj);
    Log.BER(id_SNR) = obj.Rx.BER;
    disp(['SNR = ',num2str(Log.SNR(id_SNR))])
    Reset(obj);
    toc;tic;
end

figure(999);
semilogy(Log.SNR+pow2db(1), Log.BER, 'r');
hold on;
mQAM = Bound.BER_mQAM;
mQAM.PlotType = 'EsNo-BER';
mQAM.ShowBER;