classdef OpticalXCoupler < Optical_
    %OpticalXCoupler v1.0, Lingchen Huang, 2015/4/14
    % 
    
    methods
        function obj = OpticalXCoupler(varargin)
            SetVariousProp(obj, varargin{:})
        end
    end
        
    methods (Static)
        function [y1,y2] = Processing(x1, x2)
            if nargin < 2
                x2 = Copy(x1);
                x2.E = zeros(size(x1.E));
            end
            obj.optPS = OpticalPhaseShifter('phi', pi/2);
            obj.optAtt = OpticalAtt;
            y1 = OpticalCombiner.Processing(obj.optAtt.Processing(x1),...
                obj.optPS.Processing(obj.optAtt.Processing(x2)));
            y2 = OpticalCombiner.Processing(obj.optPS.Processing(obj.optAtt.Processing(x1)),...
                obj.optAtt.Processing(x2));
        end
        
    end
    
end

