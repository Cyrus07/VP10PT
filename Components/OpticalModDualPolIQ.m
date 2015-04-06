classdef OpticalModDualPolIQ < Optical_
    %OpticalModDualPolIQ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        DeviceAngle     = 0
        ExRatioParent
        ExRatioChild
        PhaseShift
        PushPull
        VpiRf
        VpiDC
        Bias
        ModDepth
    end
    properties (SetAccess = private)
        IQ1
        IQ2
        PBS
    end
    
    methods
        
        function obj = OpticalModDualPolIQ( varargin )
            SetVariousProp(obj, varargin{:})
            Init(obj);
        end
        
        function Init(obj)
            obj.PBS = OpticalPolSplitter('DeviceAngle', obj.DeviceAngle);
            obj.IQ1 = OpticalModIQ('ExRatioParent', obj.ExRatioParent, ...
                'ExRatioChild', obj.ExRatioChild, ...
                'PhaseShift', obj.PhaseShift, ...
                'PushPull', obj.PushPull, ...
                'VpiRf', obj.VpiRf, ...
                'VpiDC', obj.VpiDC, ...
                'Bias', obj.Bias,...
                'ModDepth', obj.ModDepth);
            obj.IQ2 = OpticalModIQ('ExRatioParent', obj.ExRatioParent, ...
                'ExRatioChild', obj.ExRatioChild, ...
                'PhaseShift', obj.PhaseShift, ...
                'PushPull', obj.PushPull, ...
                'VpiRf', obj.VpiRf, ...
                'VpiDC', obj.VpiDC, ...
                'Bias', obj.Bias,...
                'ModDepth', obj.ModDepth);
        end
        
        function y = Processing(obj, x, rf1, rf2)
            Check(x, 'OpticalSignal');
            Check(rf1, 'ElectricalSignal');
            Check(rf2, 'ElectricalSignal');
            y = Copy(x);
            
            if obj.Active
                xpbs = obj.PBS.Processing(x);
                part1 = obj.IQ1.Processing(xpbs{1},rf1);
                part2 = obj.IQ2.Processing(xpbs{2},rf2);
                y = OpticalCombiner.Processing(part1,part2);
            else
                y.E = x.E;
            end
        end
    end
    
end

