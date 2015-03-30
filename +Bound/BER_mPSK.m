classdef BER_mPSK < Module
    %BER_mPSK coded square M-PSK theoretical ber with symbol rate of Rs
    %%
    properties
        PlotType    = 'EbNo-BER'
        OSNR        = []
        Rs          = 28e9
        EsNo        = []
        EbNo        = 0:12
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
            obj.OSNR = obj.EsNo - pow2db(12.5e9/obj.Rs);
            obj.EbNo = obj.EsNo - pow2db(k);
            
            [~, obj.SER] = berawgn(obj.EbNo, 'psk', obj.M, 'nondiff');
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
            end
            grid on;
        end
    end
end
