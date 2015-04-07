classdef OpticalPhaseShifter < Optical_
    %OpticalPhaseShifter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        phi
    end
    
    methods
        function obj = OpticalPhaseShifter(varargin)
            SetVariousProp(obj, varargin{:})
        end
        
        function yOptField = Processing(obj,xOptField)
            yOptField = Copy(xOptField);
            if obj.Active
                yOptField.E = xOptField.E.* exp(1j*obj.phi);
            else
                yOptField.E = xOptField.E;
            end
        end
    end
    
end

