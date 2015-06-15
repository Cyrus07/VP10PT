classdef CohOptB2B < Project_
    %EleB2B   v1.0, Lingchen Huang, 2015/4/1
    
    properties
        nPol            = 2;
        BitPerSymbol    = 2;
        FrameLen        = 1 * 2^14;            % [syms]
        FrameOverlapLen = 0 * 2^12;     % [syms]
        ChannelSPS      = 2
        RxSPS           = 2
    end
    properties
        Tx
        Channel
        DSP
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
            obj.Channel     = ChannelOpticalCohAWGN;
            obj.Rx          = DecisionHard;
            obj.DSP         = SingleCarrierDSP1;
            obj.Scope       = SignalAnalyzer;
            
            obj.Tx.FrameLen = obj.FrameLen;
            obj.Tx.FrameOverlapLen = obj.FrameOverlapLen;
            obj.Tx.mn = obj.BitPerSymbol^2;
            obj.Tx.nPol = obj.nPol;
            obj.Tx.FECType = 'LDPC';
            Init(obj.Tx);
            
            obj.Channel.nPol = obj.nPol;
            obj.Channel.FrameOverlapRatio = obj.FrameOverlapLen / obj.FrameLen;
            obj.Channel.FrameLen = obj.FrameLen * obj.ChannelSPS;
            obj.Channel.SymbolRate = 28e9;
            obj.Channel.SamplingRate = obj.Channel.SymbolRate * obj.ChannelSPS;
            obj.Channel.RxSamplingRate = obj.Channel.SymbolRate * obj.RxSPS;
            obj.Channel.TxBandwidth = 50e9;
            obj.Channel.PDBandwidth = 21e9;
            obj.Channel.RxBandwidth = 50e9;
            obj.Channel.SamplingPhase = ceil(obj.ChannelSPS/obj.RxSPS/2);
            Init(obj.Channel);
            
            obj.Rx.nPol = obj.nPol;
            obj.Rx.FECType = obj.Tx.PRBS.BinarySource{1}.FECType;
            obj.Rx.hMod = obj.Tx.Mod.h;
%             obj.Rx.DispEVM = true;
            obj.Rx.TCErrorCount = 0;
            obj.Rx.TCBitCount = 0;
            Init(obj.Rx);
            
            obj.DSP.sps = obj.RxSPS;
            obj.DSP.mn = obj.Tx.mn;
            obj.DSP.Rs = obj.Channel.SymbolRate;
            obj.DSP.nPol = obj.nPol;
            Init(obj.DSP);
        end
        %%
        function Processing(obj)
            
            while true
                
                tx = obj.Tx.Processing;
                ch = obj.Channel.Processing(tx);
                dsp = obj.DSP.Processing(ch);
%                 obj.Scope.Processing(dsp{1})
                obj.Rx.RefMsg = obj.Tx.PRBS.RefMsg;
                obj.Rx.Processing(dsp);
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