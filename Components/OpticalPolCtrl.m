classdef OpticalPolCtrl < Optical_
    %OpticalPolCtrl v1.0, Lingchen Huang, 2015/4/3
    
    properties
        Azimuth = 0.0;
        Ellipticity = 0.0;
    end
    properties (SetAccess = private)
        JonesVector
    end
    
    methods
        function obj = OpticalPolCtrl(varargin)
            SetVariousProp(obj, varargin{:})
        end
        
        function y = Processing(obj, x)
            Check(x, 'OpticalSignal');
            y = Copy(x);
            if obj.Active

                while abs(obj.Azimuth) > 90
                    obj.Azimuth = (abs(obj.Azimuth)-180) * sign(obj.Azimuth);
                end
                while abs(obj.Ellipticity) > 45
                    obj.Ellipticity = (abs(obj.Ellipticity)-90) * sign(obj.Ellipticity);
                end
                
                % convert to radius
                ita = obj.Azimuth / 180 * pi;
                eps = obj.Ellipticity / 180 * pi;
                
                % get the power split ratio
                k = ( 1 - cos(2*ita)*cos(2*eps) ) / 2;
                
                % get the phase difference
                if k == 0 || k == 1
                    d = 0;
                else
                    d = asin( sin(2*eps) / 2 / sqrt(k*(1-k)) );
                end
                
                obj.JonesVector = [sqrt(1-k);
                    sqrt(k) * exp(1j*d)];
                
                % if it is in Western Hemisphere %
                if ita<0
                    obj.JonesVector = [sqrt(1-k);
                        -sqrt(k) * exp(1j*-d)];
                end
                
                % select the reference phase %
                if ~any(x.E)
                    y.E = obj.JonesVector * sqrt(sum(abs(x.E).^2)).* [sign(x.Ey);sign(x.Ey)];
                else
                    y.E = obj.JonesVector * sqrt(sum(abs(x.E).^2)).* [sign(x.Ex);sign(x.Ex)];
                end
                
                y.Azi = obj.Azimuth;
                y.Ell = obj.Ellipticity;
            else
                y.E = x.E;
            end
        end
    end
    
end

