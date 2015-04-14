classdef OpticalPolSplitter < Optical_
    %OpticalPolSplitter v1.0, Lingchen Huang, 2015/4/6
    %   this polarization splitter consists two linear polarizers:
    %   horizontal and vertical
    
    properties
        %% degree
        DeviceAngle = 0;
    end
    
    properties (SetAccess = private)
        LPH
        LPV
    end
    
    methods
        function obj = OpticalPolSplitter(varargin)
            SetVariousProp(obj, varargin{:})
        end
        function Init(obj)
            obj.LPH = OpticalPolLnr('DeviceAngle',obj.DeviceAngle);
            obj.LPV = OpticalPolLnr('DeviceAngle',obj.DeviceAngle + 90);
        end
        function y = Processing(obj, x)
            Init(obj);
            y{1} = obj.LPH.Processing( x );
            y{2} = obj.LPV.Processing( x );
        end
    end
    
end

