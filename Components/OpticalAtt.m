classdef OpticalAtt < Optical_
    %OpticalAtt v1.0, Lingchen Huang, 2015/4/14
    % 
    
    properties
        Att = 3 % power attenuation ratio, [dB]
    end
    
    methods
        function obj = OpticalAtt(varargin)
            SetVariousProp(obj, varargin{:})
        end
        
        function y = Processing(obj, x)
            y = Copy(x);
            y.E = x.E / (db2pow(obj.Att)/sqrt(2));
        end
        
    end
    
end