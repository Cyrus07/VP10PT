classdef RxOpticalCohDP < Subsystem_ & Optical_
    %RxOpticalCohDP v1.0, Lingchen Huang, 2015/4/14
    
    properties
        FrameOverlapRatio
        FrameLen
        SamplingRate
        LaserPower
        LaserLinewidth
        LaserInitPhase
        LaserFrequency
        LaserAzimuth
        LaserEllipticity
        DeviceAngle
        HybridPhaseShift
        PDResponsivity
        PDAddNoise
        PDBandwidth
        RxSamplingRate
        SamplingPhase
        ADCResolution
        Bandwidth
        FilterOrder
        FilterShape
        FilterDomain
    end
    properties
        Laser
        PBS
        Hybrid
        BPD
        Sampler
        ADC
        LPF
        Scope
    end
    
    methods
        %%
        function obj = RxOpticalCohDP(varargin)
            SetVariousProp(obj, varargin{:})
            Init(obj);
        end
        %%
        function y = Processing(obj, x)
            
            cw = obj.Laser.Processing(length(x.Ex));
            lo = obj.PBS.Processing(cw);
            [xI,xQ] = obj.Hybrid.Processing(x, lo{1});
            [yI,yQ] = obj.Hybrid.Processing(x, lo{2});
            pd{1}   = obj.BPD{1}.Processing(xI);
            pd{2}   = obj.BPD{2}.Processing(xQ);
            pd{3}   = obj.BPD{3}.Processing(yI);
            pd{4}   = obj.BPD{4}.Processing(yQ);
            sa      = obj.Sampler.Processing(pd);
            adc     = obj.ADC.Processing(sa);
            y       = obj.LPF.Processing(adc);
            
        end
        %%
        function Init(obj)
            obj.Laser 	= OpticalLaserCW('OverlapRatio', obj.FrameOverlapRatio,...
                'BufferLength', obj.FrameLen,...
                'SamplingRate', obj.SamplingRate,...
                'CenterFrequency', obj.LaserFrequency,...
                'OutputPower', obj.LaserPower ,...
                'Linewidth', obj.LaserLinewidth ,...
                'InitialPhase', obj.LaserInitPhase,...
                'Azimuth', obj.LaserAzimuth, ...
                'Ellipticity', obj.LaserEllipticity);
            obj.PBS     = OpticalPolSplitter('DeviceAngle', obj.DeviceAngle);
            obj.Hybrid  = OpticalHybrid('HybridPhaseShift', obj.HybridPhaseShift);
            
            obj.BPD{1} = OpticalBPD('OverlapRatio', obj.FrameOverlapRatio, ...
                'BufferLength', obj.FrameLen,...
                'Responsivity', obj.PDResponsivity, ...
                'Bandwidth', obj.PDBandwidth, ...
                'LPF', ~isempty(obj.PDBandwidth), ...
                'AddNoise', obj.PDAddNoise);
            obj.BPD{2} = OpticalBPD('OverlapRatio', obj.FrameOverlapRatio, ...
                'BufferLength', obj.FrameLen,...
                'Responsivity', obj.PDResponsivity, ...
                'Bandwidth', obj.PDBandwidth, ...
                'LPF', ~isempty(obj.PDBandwidth), ...
                'AddNoise', obj.PDAddNoise);
            obj.BPD{3} = OpticalBPD('OverlapRatio', obj.FrameOverlapRatio, ...
                'BufferLength', obj.FrameLen,...
                'Responsivity', obj.PDResponsivity, ...
                'Bandwidth', obj.PDBandwidth, ...
                'LPF', ~isempty(obj.PDBandwidth), ...
                'AddNoise', obj.PDAddNoise);
            obj.BPD{4} = OpticalBPD('OverlapRatio', obj.FrameOverlapRatio, ...
                'BufferLength', obj.FrameLen,...
                'Responsivity', obj.PDResponsivity, ...
                'Bandwidth', obj.PDBandwidth, ...
                'LPF', ~isempty(obj.PDBandwidth), ...
                'AddNoise', obj.PDAddNoise);
            obj.Sampler	= EleSampler('SamplingRate', obj.RxSamplingRate,...
                'SamplingPhase', obj.SamplingPhase);
            obj.ADC 	= EleQuantizer('Resolution', obj.ADCResolution);
            obj.LPF  	= EleLPF('Bandwidth', obj.Bandwidth,...
                'FilterOrder', obj.FilterOrder,...
                'FilterShape', obj.FilterShape,...
                'FilterDomain', obj.FilterDomain);
            obj.Scope   = SignalAnalyzer;
        end
        %%
        function Reset(obj)
            Reset(obj.Laser)
            Reset(obj.BPD{1})
            Reset(obj.BPD{2})
            Reset(obj.BPD{3})
            Reset(obj.BPD{4})
        end
    end
end
