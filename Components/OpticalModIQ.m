classdef OpticalModIQ < Optical_
    %OpticalModIQ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PhaseShift      = 90
        ExRatioParent   = 35
        ExRatioChild
        PushPull
        VpiRf
        VpiDC
        Bias
        ModDepth
    end
    properties (SetAccess = private)
        Mz_upper
        Mz_lower
        optPS
    end
    properties (Dependent, SetAccess = private)
        PowerSplitRatio
        AmplitudeSplitRatio
    end
    
    methods
        
        function obj = OpticalModIQ( varargin )
            SetVariousProp(obj, varargin{:})
            Init(obj);
        end
        
        function Init(obj)
            obj.Mz_upper = OpticalModMz('ExRatio', obj.ExRatioChild, ...
                'PushPull', obj.PushPull, ...
                'VpiRf', obj.VpiRf, ...
                'VpiDC', obj.VpiDC, ...
                'Bias', obj.Bias,...
                'ModDepth', obj.ModDepth);
            obj.Mz_lower = OpticalModMz('ExRatio', obj.ExRatioChild, ...
                'PushPull', obj.PushPull, ...
                'VpiRf', obj.VpiRf, ...
                'VpiDC', obj.VpiDC, ...
                'Bias', obj.Bias,...
                'ModDepth', obj.ModDepth);
            obj.optPS = OpticalPhaseShifter('phi',obj.PhaseShift/180*pi);
        end
        
        function asr = get.AmplitudeSplitRatio(obj)
            if obj.ExRatio >= 99
                asr = [sqrt(2)/2,sqrt(2)/2];
            else
                Imperfect = sqrt(1/10^(obj.ExRatioParent/10));
                Yupper = sqrt(0.5+Imperfect);
                Ylower = sqrt(1-Yupper^2);
                asr = [Yupper,Ylower];
            end
        end
        
        function psr = get.PowerSplitRatio(obj)
            psr = obj.AmplitudeSplitRatio.^2;
        end
        
        function y = Processing(obj, x, rf)
            Check(x, 'OpticalSignal');
            Check(rf, 'ElectricalSignal');
            y = Copy(x);
            
            if obj.Active
                rf1 = Copy(rf);
                rf1.E = real(rf.E);
                rf2 = Copy(rf);
                rf2.E = imag(rf.E);
                %
                part_i = obj.Mz_upper.Processing(x,rf1,rf1);
                part_q = obj.Mz_lower.Processing(x,rf2,rf2);
                % combine i q
                y = OpticalCombiner.Processing(part_i,...
                    obj.optPS.Processing(part_q));
            else
                y.E = x.E;
            end
        end
    end
    
end

