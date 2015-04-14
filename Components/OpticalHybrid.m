classdef OpticalHybrid < Optical_
    %OpticalHybrid v1.0, Lingchen Huang, 2015/4/14
    
    
    properties
        HybridPhaseShift = 90
    end
    
    properties (SetAccess = private)
        optPS
    end
    
    methods
        
        function obj = OpticalHybrid(varargin)
            SetVariousProp(obj, varargin{:})
            Init(obj);
        end
        
        function Init(obj)
            obj.optPS = OpticalPhaseShifter;
        end
        
        function Reset(obj)
            Init(obj)
        end
        
        function [yI,yQ] = Processing(obj, x, lo)
            
            yI{1} = OpticalCombiner.Processing(x,lo);
            obj.optPS.phi = pi;
            yI{2} = OpticalCombiner.Processing(x,obj.optPS.Processing(lo));
            obj.optPS.phi = obj.HybridPhaseShift/180*pi; 
            yQ{1} = OpticalCombiner.Processing(x,obj.optPS.Processing(lo));
            obj.optPS.phi = obj.HybridPhaseShift/180*pi + pi; 
            yQ{2} = OpticalCombiner.Processing(x,obj.optPS.Processing(lo));
        end
        
    end
    
end

