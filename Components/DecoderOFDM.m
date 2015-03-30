classdef DecoderOFDM < Module
    % copyright2014 lingchen
    % last modified @ 2014 , lingchen
    %%
    properties
        OFDM
        PilotSequence
    end
    properties (GetAccess = protected)
        Input
    end
    properties (SetAccess = protected)
        DecodeBuf = BUFFER
        Data
        Pilot
    end
    methods
        %%
        function obj = DecoderOFDM(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Processing(obj)
            if isempty(obj.Input)
                return;
            end
            obj.DecodeBuf.Input(obj.Input);
            obj.OFDM;
            nblock = floor(length(obj.DecodeBuf.Buffer)...
                /(obj.OFDM.nFFT + obj.OFDM.nGI));
            syms = obj.DecodeBuf.Output(nblock*(obj.OFDM.nFFT + obj.OFDM.nGI));
            syms = reshape(syms, obj.OFDM.nFFT + obj.OFDM.nGI, []);
            pre = round(obj.OFDM.nGI/2);
            post = obj.OFDM.nGI - pre;
            syms = syms(pre+1:end-post,:);
            syms = sqrt(obj.OFDM.nFFT)*fft(syms);
            obj.Data = syms(obj.OFDM.IdxSubCarr,:);
            obj.Pilot = syms(obj.OFDM.IdxPilot,:) ...
                ./ repmat(obj.PilotSequence,1,nblock);
        end
    end
    
end

