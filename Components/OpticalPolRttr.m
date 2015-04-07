classdef OpticalPolRttr < Optical_
    %PolRotator v1.0, Lingchen Huang, 2015/4/1
    
    properties
        Azimuth = 0;
        Ellipticity = 0.0;
    end
    
    properties (SetAccess = private)
        JonesMatrix;
    end
    
    methods
        function obj = OpticalPolRttr(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function y = Processing(obj, x)
            Check(x, 'OpticalSignal');
            y = Copy(x);
            if obj.Active
                while abs(obj.Azimuth) > 90
                    obj.Azimuth = (abs(obj.Azimuth)-180) * sign(obj.Azimuth);
                end
                theta = obj.Azimuth / 180 * pi;
                while abs(obj.Ellipticity) > 45
                    obj.Ellipticity = (abs(obj.Ellipticity)-90) * sign(obj.Ellipticity);
                end
                phi = obj.Ellipticity /180 * pi;
                obj.JonesMatrix = [cos(theta)*exp(-1i*phi/2) -sin(theta)*exp(1i*phi/2); ...
                    sin(theta)*exp(-1i*phi/2)  cos(theta)*exp(1i*phi/2)];
                
                y.E = x.E * obj.JonesMatrix.';
                
            else
                y.E = x.E;
            end
        end
        
    end
    
end

