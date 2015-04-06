classdef OpticalPolLnr < Optical_
    %POLARIZERLINEAR Summary of this class goes here
    %   This ideal linear polarizer contains 3 steps: rotate the
    %   transmission axis to the device axis (-theta); pass the signal throught a
    %   x-orientation linear polarizer; rotate the transmission axis back (+theta).
    
    %   Copyright2011 wangdawei
    
    properties
        DeviceAngle = 0
    end
    
    properties (SetAccess = private)
        JonesMatrix;
    end
    
    methods
        function obj = OpticalPolLnr(varargin)
            SetVariousProp(obj, varargin{:})
            Init(obj)
        end
        
        function Init(obj)
            theta = obj.norm_azimuth;
            obj.JonesMatrix = ...
                [cos(theta) -sin(theta); ...
                sin(theta) cos(theta)] * ...
                [1 0; 0 0] * ...
                [cos(-theta) -sin(-theta); ...
                sin(-theta) cos(-theta)];
        end
        
        function y = Processing(obj, x)
            if obj.Active
                y = Copy(x);
                y.E = x.E * obj.JonesMatrix.';
            else
                y = x;
            end
        end
    end
    
    methods (Access = private)
        % nomarlize the device angle and convert it to radian
        function y = norm_azimuth(obj)
            x = obj.DeviceAngle;
            while abs(x) > 90
                x = (abs(x)-180) * sign(x);
            end
            y = x*pi/180;
            obj.DeviceAngle = x;
        end
        % the range for device angle is -90:+90
    end
    
end

