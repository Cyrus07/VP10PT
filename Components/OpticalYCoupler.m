classdef OpticalYCoupler < Optical_
    %OpticalYCoupler v1.0, Lingchen Huang, 2015/4/15
    % 
    
    methods
        function obj = OpticalYCoupler(varargin)
            SetVariousProp(obj, varargin{:})
        end
    end
        
    methods (Static)
        function [y1,y2] = Processing(x)
            obj.optAtt = OpticalAtt;
            y1 = obj.optAtt.Processing(x);
            y2 = obj.optAtt.Processing(x);
        end
        
    end
    
end