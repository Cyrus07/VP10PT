classdef BER_mQAM < Module
    %BER_mQAM Gray coded square M-QAM theoretical ber with symbol rate of Rs
    %%
    properties
        PlotType    = 'EbNo-BER'
        OSNR        = []
        EsNo        = []
        EbNo        = 0:12
        SNR         = []
        Rs          = 28e9
        fs          = 28e9
        M           = 4
        BER
        SER
    end
    
    methods
        %%
        function ShowBER(obj)
            k = log2(obj.M);
            if ~isempty(obj.OSNR)
                obj.EsNo = obj.OSNR + pow2db(12.5e9/obj.Rs);
            end
            if ~isempty(obj.EbNo)
                obj.EsNo = obj.EbNo + pow2db(k);
            end
            if ~isempty(obj.SNR)
                obj.EsNo = obj.SNR + pow2db(obj.fs/obj.Rs);
            end
            obj.SNR  = obj.EsNo - pow2db(obj.fs/obj.Rs);
            obj.OSNR = obj.EsNo - pow2db(12.5e9/obj.Rs);
            obj.EbNo = obj.EsNo - pow2db(k);
            
            [~, obj.SER] = berawgn(obj.EbNo, 'qam', obj.M, 'nondiff');
            obj.BER = obj.SER / k;
            switch lower(obj.PlotType)
                case 'ebno-ber'
                    semilogy(obj.EbNo, obj.BER);
                case 'ebno-ser'
                    semilogy(obj.EbNo, obj.SER);
                case 'esno-ber'
                    semilogy(obj.EsNo, obj.BER);
                case 'esno-ser'
                    semilogy(obj.EsNo, obj.SER);
                case 'osnr-ber'
                    semilogy(obj.OSNR, obj.BER);
                case 'osnr-ser'
                    semilogy(obj.OSNR, obj.SER);
                case 'snr-ber'
                    semilogy(obj.SNR, obj.BER);
                case 'snr-ser'
                    semilogy(obj.SNR, obj.SER);
            end
            grid on;
        end
    end
end
