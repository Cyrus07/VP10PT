classdef CohOptB2B < Project_
    %EleB2B   v1.0, Lingchen Huang, 2015/4/1
    
    properties
        nPol            = 2;
        BitPerSymbol    = 2;
        FrameLen        = 4 * 2^10;            % [syms]
        FrameOverlapLen = 2 * 2^10;     % [syms]
        ChannelSPS      = 8
        RxSPS           = 1
    end
    properties
        Tx
        Channel
        Rx
        Scope
    end
    methods
        %%
        function obj = CohOptB2B(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Init(obj)
            obj.Tx          = TxCoderCoh;
            obj.Channel     = ChannelCohOptAWGN;
            obj.Rx          = DecisionHard;
            
            obj.Tx.FrameLen = obj.FrameLen;
            obj.Tx.FrameOverlapLen = obj.FrameOverlapLen;
            obj.Tx.mn = obj.BitPerSymbol^2;
            obj.Tx.nPol = obj.nPol;
            Init(obj.Tx);
            
            obj.Channel.nPol = obj.nPol;
            obj.Channel.FrameOverlapRatio = obj.FrameOverlapLen / obj.FrameLen;
            obj.Channel.SymbolRate = 28e9;
            obj.Channel.ChSamplingRate = 28e9 * obj.ChannelSPS;
            obj.Channel.TxBandwidth = 20e9;
            obj.Channel.TxFilterShape = 'Bessel';
            obj.Channel.TxFilterDomain = 'FD';
            obj.Channel.RxBandwidth = 20e9;
            obj.Channel.RxFilterShape = 'Bessel';
            obj.Channel.RxFilterDomain = 'FD';
            obj.Channel.RxSamplingRate = 28e9 * obj.RxSPS;
            obj.Channel.SamplingPhase = 1;
            obj.Channel.ChBufLen = obj.FrameLen * obj.ChannelSPS;
            Init(obj.Channel);
            
            obj.Rx.nPol = obj.nPol;
            obj.Rx.FECType = obj.Tx.PRBS.BinarySource{1}.FECType;
            obj.Rx.hMod = obj.Tx.Mod.h;
            Init(obj.Rx);
            
            obj.Scope = SignalAnalyzer;
        end
        %%
        function Processing(obj)
            
            while true
                
                tx = obj.Tx.Processing;
                ch = obj.Channel.Processing(tx);
                
                obj.Rx.RefMsg = obj.Tx.PRBS.RefMsg;
                obj.Rx.Processing(ch);
                
                if ~isempty(obj.Rx.BER)
                    break;
                end
            end
            
        end
        %%
        function Reset(obj)
            Reset(obj.Tx);
            Reset(obj.Channel);
            Reset(obj.Rx);
        end
    end
end