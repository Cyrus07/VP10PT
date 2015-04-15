classdef TxOpticalCoh < Subsystem_ & Optical_
    %TxOpticalCoh v1.0, Lingchen Huang, 2015/4/14
    
    properties
        FrameOverlapRatio
        FrameLen
        SamplingRate
        % Tx DSP
        
        % DAC
        Resolution
        % Rectpulse
        SymbolRate
        ChSamplingRate
        % LPF
        Bandwidth
        FilterOrder
        FilterShape
        FilterDomain
        % Laser
        LaserPower
        LaserLinewidth
        LaserInitPhase
        LaserFrequency
        % IQ Modulator
        DeviceAngle
        PhaseShift
        VpiRf
        VpiDC
        ExRatioParent
        ExRatioChild
        Bias
        ModDepth
    end
    properties
        DAC
        Rectpulse
        LPF
        Laser
        Mod
        Scope
    end
    
    methods
        %%
        function obj = TxOpticalCoh(varargin)
            SetVariousProp(obj, varargin{:})
            Init(obj);
        end
        %%
        function y = Processing(obj, x)
            
            dac = obj.DAC.Processing(x);
            rect = obj.Rectpulse.Processing(dac);
            lpf = obj.LPF.Processing(rect);
            cw = obj.Laser.Processing(length(lpf{1}.E));
            y = obj.Mod.Processing(cw, lpf);
            
        end
        %%
        function Init(obj)
            obj.DAC         = EleQuantizer('Resolution', obj.Resolution);
            obj.Rectpulse   = EleRectPulse('SymbolRate', obj.SymbolRate,...
                'SamplingRate', obj.SamplingRate);
            obj.LPF       = EleLPF('Bandwidth', obj.Bandwidth,...
                'FilterOrder', obj.FilterOrder,...
                'FilterShape', obj.FilterShape,...
                'FilterDomain', obj.FilterDomain);
            obj.Laser       = OpticalLaserCW('OverlapRatio', obj.FrameOverlapRatio,...
                'BufferLength', obj.FrameLen,...
                'SamplingRate', obj.SamplingRate,...
                'CenterFrequency', obj.LaserFrequency,...
                'OutputPower', obj.LaserPower ,...
                'Linewidth', obj.LaserLinewidth ,...
                'InitialPhase', obj.LaserInitPhase);
            obj.Mod         = OpticalModDualPolIQ('DeviceAngle', obj.DeviceAngle,...
                'PhaseShift', obj.PhaseShift, ...
                'ExRatioParent', obj.ExRatioParent, ...
                'ExRatioChild', obj.ExRatioChild, ...
                'VpiRf', obj.VpiRf, ...
                'VpiDC', obj.VpiDC, ...
                'Bias', obj.Bias,...
                'ModDepth', obj.ModDepth);
            obj.Scope = SignalAnalyzer;
        end
        %%
        function Reset(obj)
            Reset(obj.Laser)
        end
    end
end
