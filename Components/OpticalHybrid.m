classdef OpticalHybrid < Optical_
    %OpticalHybrid v1.0, Lingchen Huang, 2015/4/14
    % This module is to do hybrd mixer between two optical fields.
    % 
    
    
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
            obj.optPS.phi = -pi/2;
            [x1, x2] = OpticalXCoupler.Processing(x);
            [lo1, lo2] = OpticalXCoupler.Processing(lo);
            [yI{1}, yI{2}] = OpticalXCoupler.Processing(x1, obj.optPS.Processing(lo1));
            [yQ{1}, yQ{2}] = OpticalXCoupler.Processing(x2, lo2);
        end
        
    end
    
end

