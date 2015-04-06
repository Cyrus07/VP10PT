classdef OpticalPolLnr < Module
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
        function this = OpticalPolLnr(varargin)
            SetVariousProp(this, varargin{:})
        end
        
        function reset(this)
            theta = this.norm_azimuth;
            this.JonesMatrix = ...
                [cos(theta) -sin(theta); ...
                sin(theta) cos(theta)] * ...
                [1 0; 0 0] * ...
                [cos(-theta) -sin(-theta); ...
                sin(-theta) cos(-theta)];
        end
        
        function y = Output(this, x)
            if this.Active
                reset(this)
                y = copy(x);
                y.E = this.JonesMatrix * x.E;
                y.Azi = this.DeviceAngle;
                y.Ell = 0;
            else
                y = x;
            end
        end
    end
    
    methods (Access = private)
        % nomarlize the device angle and convert it to radian
        function y = norm_azimuth(this)
            x = this.DeviceAngle;
            while abs(x) > 90
                x = (abs(x)-180) * sign(x);
            end
            y = x*pi/180;
            this.DeviceAngle = x;
        end
        % the range for device angle is -90:+90
    end
    
end

