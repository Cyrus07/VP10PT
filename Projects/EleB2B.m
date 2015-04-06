classdef EleB2B < Project_
    %EleB2B   v1.0, Lingchen Huang, 2015/4/1
    
    properties
        nPol = 1;
        BitPerSymbol = 2;
        FrameLen = 4 * 2^10;            % [syms]
        FrameOverlapLen = 2 * 2^10;     % [syms]
    end
    properties
        Tx
        Channel
        Rx
    end
    methods
        %%
        function obj = EleB2B(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Init(obj)
            obj.Tx          = TxCoderCoh;
            obj.Channel     = ChannelEleAWGN;
            obj.Rx          = DecisionHard;
            
            obj.Tx.FrameLen = obj.FrameLen;
            obj.Tx.FrameOverlapLen = obj.FrameOverlapLen;
            obj.Tx.mn = obj.BitPerSymbol^2;
            obj.Tx.nPol = obj.nPol;
            Init(obj.Tx);
            
            obj.Channel.nPol = obj.nPol;
            obj.Channel.FrameOverlapRatio = obj.FrameOverlapLen / obj.FrameLen;
            obj.Channel.SymbolRate = 28e9;
            obj.Channel.TxSamplingRate = 28e9 * 1;
            obj.Channel.TxBandwidth = 50e9;
            obj.Channel.TxFilterShape = 'Gaussian';
            obj.Channel.TxFilterDomain = 'TD';
            obj.Channel.RxBandwidth = 50e9;
            obj.Channel.RxFilterShape = 'Gaussian';
            obj.Channel.RxFilterDomain = 'TD';
            obj.Channel.RxSamplingRate = 28e9 * 1;
            obj.Channel.SamplingPhase = 1;
            obj.Channel.ChBufLen = obj.FrameLen * 1;
            Init(obj.Channel);
            
            obj.Rx.nPol = obj.nPol;
            obj.Rx.FECType = obj.Tx.PRBS.BinarySource{1}.FECType;
            obj.Rx.hMod = obj.Tx.Mod.h;
            Init(obj.Rx);
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