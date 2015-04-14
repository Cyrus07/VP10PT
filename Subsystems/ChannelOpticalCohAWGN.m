classdef ChannelOpticalCohAWGN < Subsystem_
    %ChannelOpticalCohAWGN   v1.0, Lingchen Huang, 2015/4/1
    
    properties
        nPol
        FrameOverlapRatio
        FrameLen
        %%
        % Tx DSP
        
        % DAC
        DACResolution
        % Rectpulse
        SymbolRate
        SamplingRate
        % Tx LPF
        TxBandwidth
        TxFilterOrder
        TxFilterShape
        TxFilterDomain
        % Tx Laser
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
        %% Opt AWGN Channel
        OSNR
        %%
        % Rx Laser
        RxLaserPower
        RxLaserLinewidth
        RxLaserInitPhase
        RxLaserFrequency
        RxLaserAzimuth
        RxLaserEllipticity
        % Coherent receiver
        RxDeviceAngle
        HybridPhaseShift
        PDResponsivity
        PDDarkCurrent
        PDTemperature
        PDLoadResistance
        PDAddNoise = true
        PDBandwidth
        % Sampler
        RxSamplingRate
        SamplingPhase
        % ADC
        ADCResolution
        % Rx LPF
        RxBandwidth
        RxFilterOrder
        RxFilterShape
        RxFilterDomain
    end
    properties
        Tx
        Ch
        Rx
        DeO
        Scope
    end
    
    methods
        %%
        function obj = ChannelOpticalCohAWGN(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function y = Processing(obj, x)
            tx = obj.Tx.Processing(x);
            ch = obj.Ch.Processing(tx);
            rx = obj.Rx.Processing(ch);
            de = obj.DeO.Processing(rx);
            y{1} = de{1} + 1i * de{2};
            y{2} = de{3} + 1i * de{4};
        end
        %%
        function Init(obj)
            obj.Tx  = TxOpticalCoh('FrameOverlapRatio', obj.FrameOverlapRatio,...
                'FrameLen', obj.FrameLen,...
                'Resolution', obj.DACResolution,...
                'SymbolRate', obj.SymbolRate,...
                'SamplingRate', obj.SamplingRate,...
                'Bandwidth', obj.TxBandwidth,...
                'FilterOrder', obj.TxFilterOrder,...
                'FilterShape', obj.TxFilterShape,...
                'FilterDomain', obj.TxFilterDomain,...
                'LaserPower', obj.TxLaserPower,...
                'LaserLinewidth', obj.TxLaserLinewidth,...
                'LaserInitPhase', obj.TxLaserInitPhase,...
                'LaserFrequency', obj.TxLaserFrequency,...
                'DeviceAngle', obj.ModDeviceAngle,...
                'PhaseShift', obj.ModPhaseShift,...
                'VpiRf', obj.VpiRf,...
                'VpiDC', obj.VpiDC,...
                'ExRatioParent', obj.ExRatioParent,...
                'ExRatioChild', obj.ExRatioChild,...
                'Bias', obj.ModBias,...
                'ModDepth', obj.ModDepth);
            obj.Ch 	= ChOptAWGN('nPol', obj.nPol,...
                'FrameLen', obj.FrameLen,...
                'FrameOverlapRatio', obj.FrameOverlapRatio);
            obj.Rx  = RxOpticalCohDP('FrameOverlapRatio', obj.FrameOverlapRatio,...
                'FrameLen', obj.FrameLen,...
                'SamplingRate', obj.SamplingRate,...
                'LaserPower', obj.RxLaserPower,...
                'LaserLinewidth', obj.RxLaserLinewidth,...
                'LaserInitPhase', obj.RxLaserInitPhase,...
                'LaserFrequency', obj.RxLaserFrequency,...
                'LaserAzimuth', obj.RxLaserAzimuth,...
                'LaserEllipticity', obj.RxLaserEllipticity,...
                'DeviceAngle', obj.RxDeviceAngle,...
                'HybridPhaseShift', obj.HybridPhaseShift,...
                'PDResponsivity', obj.PDResponsivity,...
                'PDAddNoise', obj.PDAddNoise,...
                'PDBandwidth', obj.PDBandwidth,...
                'RxSamplingRate', obj.RxSamplingRate,...
                'SamplingPhase', obj.SamplingPhase,...
                'ADCResolution', obj.ADCResolution,...
                'Bandwidth', obj.RxBandwidth,...
                'FilterOrder', obj.RxFilterOrder,...
                'FilterShape', obj.RxFilterShape,...
                'FilterDomain', obj.RxFilterDomain);
            obj.DeO	= DeOverlap('nPol', obj.nPol * 2,...
                'FrameOverlapRatio', obj.FrameOverlapRatio);
            obj.Scope = SignalAnalyzer;
        end
        %%
        function Reset(obj)
            Reset(obj.Tx)
            Reset(obj.Ch);
            Reset(obj.Rx);
            Reset(obj.DeO);
        end
    end
end
