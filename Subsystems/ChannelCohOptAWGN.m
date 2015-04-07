classdef ChannelCohOptAWGN < Subsystem_
    %ChannelEleAWGN   v1.0, Lingchen Huang, 2015/4/1
    
    properties
        nPol
        FrameOverlapRatio
        % Tx DSP
        
        % DAC
        DAC
        DACResolution
        % Rectpulse
        Rectpulse
        SymbolRate
        ChSamplingRate
        % Tx LPF
        LPFTx
        TxBandwidth
        TxFilterOrder
        TxFilterShape
        TxFilterDomain
        % Tx Laser
        LaserTx
        TxLaserPower
        TxLaserLinewidth
        TxLaserInitPhase
        TxLaserFrequency
        % IQ Modulator
        ModDeviceAngle
        ModPhaseShift
        VpiRf
        VpiDC
        ExRatioParent
        ExRatioChild
        ModBias
        ModDepth
        % Opt AWGN Channel
        Ch
        OSNR
        ChBufLen
        % Rx Laser
        LaserRx
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
        PBS
        Mod
        Scope
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
            cwtx = obj.LaserTx.Processing(length(lpftx{1}.E));
            tx = obj.Mod.Processing(cwtx, lpftx);
            ch = obj.Ch.Processing(tx);
            obj.Scope.Processing(ch)
            cwrx = obj.LaserRx.Processing(length(ch.Ex));
            %hyb
            lpfrx = obj.LPFRx.Processing(ch);
            sampler = obj.Sampler.Processing(lpfrx);
            adc = obj.ADC.Processing(sampler);
            y = obj.DeO.Processing(adc);
            
        end
        %%
        function Init(obj)
            obj.DAC         = EleQuantizer('Resolution', obj.DACResolution);
            obj.Rectpulse   = EleRectPulse('SymbolRate', obj.SymbolRate,...
                'SamplingRate', obj.ChSamplingRate);
            obj.LPFTx       = EleLPF('Bandwidth', obj.TxBandwidth,...
                'FilterOrder', obj.TxFilterOrder,...
                'FilterShape', obj.TxFilterShape,...
                'FilterDomain', obj.TxFilterDomain);
            obj.LaserTx     = OpticalLaserCW('SamplingRate', obj.ChSamplingRate,...
                'CenterFrequency', obj.TxLaserFrequency,...
                'OutputPower', obj.TxLaserPower ,...
                'Linewidth', obj.TxLaserLinewidth ,...
                'InitialPhase', obj.TxLaserInitPhase);
            obj.Mod         = OpticalModDualPolIQ('DeviceAngle', obj.ModDeviceAngle,...
                'PhaseShift', obj.ModPhaseShift, ...
                'ExRatioParent', obj.ExRatioParent, ...
                'ExRatioChild', obj.ExRatioChild, ...
                'VpiRf', obj.VpiRf, ...
                'VpiDC', obj.VpiDC, ...
                'Bias', obj.ModBias,...
                'ModDepth', obj.ModDepth);
            obj.Ch          = ChOptAWGN('nPol', obj.nPol,...
                'BufLen', obj.ChBufLen,...
                'FrameOverlapRatio', obj.FrameOverlapRatio);
            obj.LaserRx     = OpticalLaserCW('SamplingRate', obj.ChSamplingRate,...
                'CenterFrequency', obj.TxLaserFrequency,...
                'OutputPower', obj.TxLaserPower ,...
                'Linewidth', obj.TxLaserLinewidth ,...
                'InitialPhase', obj.TxLaserInitPhase,...
                'Azimuth', obj.RxLaserAzimuth, ...
                'Ellipticity', obj.RxLaserEllipticity);
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
            
            obj.Scope = SignalAnalyzer;
        end
        %%
        function Reset(obj)
            Reset(obj.Ch);
            Reset(obj.DeO);
        end
    end
end
