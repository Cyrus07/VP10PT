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
        IQ
        PBS
    end
    
    methods
        
        function obj = OpticalModDualPolIQ( varargin )
            SetVariousProp(obj, varargin{:})
            Init(obj);
        end
        
        function Init(obj)
            obj.PBS = OpticalPolSplitter('DeviceAngle', obj.DeviceAngle);
            obj.IQ{1} = OpticalModIQ('ExRatioParent', obj.ExRatioParent, ...
                'ExRatioChild', obj.ExRatioChild, ...
                'PhaseShift', obj.PhaseShift, ...
                'PushPull', obj.PushPull, ...
                'VpiRf', obj.VpiRf, ...
                'VpiDC', obj.VpiDC, ...
                'Bias', obj.Bias,...
                'ModDepth', obj.ModDepth);
            obj.IQ{2} = OpticalModIQ('ExRatioParent', obj.ExRatioParent, ...
                'ExRatioChild', obj.ExRatioChild, ...
                'PhaseShift', obj.PhaseShift, ...
                'PushPull', obj.PushPull, ...
                'VpiRf', obj.VpiRf, ...
                'VpiDC', obj.VpiDC, ...
                'Bias', obj.Bias,...
                'ModDepth', obj.ModDepth);
        end
        
        function y = Processing(obj, x, rf)
            Check(x, 'OpticalSignal');
            y = Copy(x);
            
            if obj.Active
                xpbs = obj.PBS.Processing(x);
                
                for npol = 1:length(rf)
                    Check(rf{npol}, 'ElectricalSignal');
                    iq{npol} = obj.IQ{npol}.Processing(xpbs{npol},rf{npol});
                end
                
                y = OpticalCombiner.Processing(iq{1:npol});
            else
                y.E = x.E;
            end
        end
    end
    
end

