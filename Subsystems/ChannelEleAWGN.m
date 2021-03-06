classdef ChannelEleAWGN < Subsystem_
    %ChannelEleAWGN   v1.0, Lingchen Huang, 2015/4/1
    
    properties
        nPol
        Input
        Output
        FrameOverlapRatio
        % DAC
        DACResolution
        % Rectpulse
        SymbolRate
        TxSamplingRate
        % Tx LPF
        TxBandwidth
        TxFilterOrder
        TxFilterShape
        TxFilterDomain
        % Channel
        Ch
        SNR
        ChBufLen
        % Rx LPF
        RxBandwidth
        RxFilterOrder
        RxFilterShape
        RxFilterDomain
        % Sampler
        RxSamplingRate
        SamplingPhase
        % ADC
        ADCResolution
        % DeOverlap
    end
    properties (SetAccess = private)
        DAC
        Rectpulse
        LPFTx
        LPFRx
        Sampler
        ADC
        DeO
    end
    
    methods
        %%
        function obj = ChannelEleAWGN(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function y = Processing(obj, x)
            
            dac = obj.DAC.Processing(x);
            rect = obj.Rectpulse.Processing(dac);
            lpftx = obj.LPFTx.Processing(rect);
            ch = obj.Ch.Processing(lpftx);
            lpfrx = obj.LPFRx.Processing(ch);
            sampler = obj.Sampler.Processing(lpfrx);
            adc = obj.ADC.Processing(sampler);
            y = obj.DeO.Processing(adc);
            
        end
        %%
        function Init(obj)
            obj.DAC         = EleQuantizer('Resolution', obj.DACResolution);
            obj.Rectpulse   = EleRectPulse('SymbolRate', obj.SymbolRate,...
                'SamplingRate', obj.TxSamplingRate);
            obj.LPFTx       = EleLPF('Bandwidth', obj.TxBandwidth,...
                'FilterOrder', obj.TxFilterOrder,...
                'FilterShape', obj.TxFilterShape,...
                'FilterDomain', obj.TxFilterDomain);
            obj.Ch          = ChEleAWGN('nPol', obj.nPol,...
                'BufLen', obj.ChBufLen,...
                'FrameOverlapRatio', obj.FrameOverlapRatio);
            Init(obj.Ch);
            obj.LPFRx       = EleLPF('Bandwidth', obj.RxBandwidth,...
                'FilterOrder', obj.RxFilterOrder,...
                'FilterShape', obj.RxFilterShape,...
                'FilterDomain', obj.RxFilterDomain);
            obj.Sampler     = EleSampler('SamplingRate', obj.RxSamplingRate,...
                'SamplingPhase', obj.SamplingPhase);
            obj.ADC         = EleQuantizer('Resolution', obj.ADCResolution);
            obj.DeO         = DeOverlap('nPol', obj.nPol,...
                'FrameOverlapRatio', obj.FrameOverlapRatio);
            Init(obj.DeO);
        end
        %%
        function Reset(obj)
            Reset(obj.Ch);
            Reset(obj.DeO);
        end
    end
end
