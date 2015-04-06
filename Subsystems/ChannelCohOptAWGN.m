classdef ChannelCohOptAWGN < Subsystem_
    %ChannelEleAWGN   v1.0, Lingchen Huang, 2015/4/1
    
    properties
        nPol
        Input
        Output
        FrameOverlapRatio
        % Tx DSP
        
        % DAC
        DAC
        DACResolution
        % Rectpulse
        Rectpulse
        SymbolRate
        TxSamplingRate
        % Tx LPF
        LPFTx
        TxBandwidth
        TxFilterOrder
        TxFilterShape
        TxFilterDomain
        % Tx Laser
        TxLaserPower
        TxLaserLinewidth
        TxLaserInitPhase
        TxLaserFrequency
        TxLaserAzimuth
        TxLaserEllipticity
        % IQ Modulator
        VpiRf
        VpiDC
        ExtinctionRatio
        ModDepth
        % Opt AWGN Channel
        Ch
        SNR
        ChBufLen
        % Rx Laser
        RxLaserPower
        RxLaserLinewidth
        RxLaserInitPhase
        RxLaserFrequency
        RxLaserAzimuth
        RxLaserEllipticity
        % Hybrid
        HybridPhaseShift
        % Balanced PD
        Responsivity
        DarkCurrent
        Temperature
        LoadResistance
        AddThermalNoise = true
        AddShotNoise = true
        LPF
        Bandwidth
        % Rx LPF
        LPFRx
        RxBandwidth
        RxFilterOrder
        RxFilterShape
        RxFilterDomain
        % Sampler
        Sampler
        RxSamplingRate
        SamplingPhase
        % ADC
        ADC
        ADCResolution
        % DeOverlap
        DeO
    end
    properties (SetAccess = private)
    end
    
    methods
        %%
        function obj = ChannelCohOptAWGN(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function y = Processing(obj, x)
            
            dac = obj.DAC.Processing(x);
            rect = obj.Rectpulse.Processing(dac);
            lpftx = obj.LPFTx.Processing(rect);
            cwtx = obj.LaserTx.Processing(length(x{1}));
            
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
            obj.LaserTx     = OpticalLaserCW('SamplingRate', obj.TxSamplingRate,...
                'CenterFrequency', obj.TxLaserFrequency,...
                'OutputPower', obj.TxLaserPower ,...
                'Linewidth', obj.TxLaserLinewidth ,...
                'InitialPhase', obj.TxLaserInitPhase ,...
                'Azimuth', obj.TxLaserAzimuth ,...
                'Ellipticity', obj.TxLaserEllipticity);
            Init(obj.LaserTx);
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
