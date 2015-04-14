classdef TxOpticalCoh < Subsystem_ & Optical_
    %TxOpticalCoh v1.0, Lingchen Huang, 2015/4/14
    
    properties
        FrameOverlapRatio
        FrameLen
        SamplingRate
        % Tx DSP
        
        % DAC
        DAC
        Resolution
        % Rectpulse
        Rectpulse
        SymbolRate
        ChSamplingRate
        % LPF
        LPF
        Bandwidth
        FilterOrder
        FilterShape
        FilterDomain
        % Laser
        Laser
        LaserPower
        LaserLinewidth
        LaserInitPhase
        LaserFrequency
        % IQ Modulator
        Mod
        DeviceAngle
        PhaseShift
        VpiRf
        VpiDC
        ExRatioParent
        ExRatioChild
        Bias
        ModDepth
    end
    properties (SetAccess = private)
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
            lpftx = obj.LPF.Processing(rect);
            cwtx = obj.Laser.Processing(length(lpftx{1}.E));
            y = obj.Mod.Processing(cwtx, lpftx);
            
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
            Reset(obj.LaserTx)
        end
    end
end
