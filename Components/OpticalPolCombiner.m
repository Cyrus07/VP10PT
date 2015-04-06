classdef OpticalPolCombiner < Optical_
    %OpticalPolCombiner Summary of this class goes here
    %   This polarization splitter consists two linear polarizers:
    %   horizontal and vertical
    
    properties
        % degree
        DeviceAngle = 0;
    end
    
    properties (SetAccess = private)
        LPH = [];
        LPV = [];
    end
    
    methods
        function obj = OpticalPolCombiner(varargin)
            SetVariousProp(obj, varargin{:})
            Init(obj);
        end
        function Init(obj)
            obj.LPH = OpticalPolLnr('DeviceAngle',obj.DeviceAngle);
            obj.LPV = OpticalPolLnr('DeviceAngle',obj.DeviceAngle + 90);
        end
        
        function y = Processing(obj, x1, x2)
            y1 = obj.LPH.Processing( x1 );
            y2 = obj.LPV.Processing( x2 );
        end
    end
    
end

