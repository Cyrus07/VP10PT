classdef OpticalSignal < SignalType
    %OPTICALSIGNAL Summary of obj class goes here
    %   Detailed explanation goes here
    
    properties
        fc  = 193.1e12
        Azi = 0
        Ell = 0
    end
    
    properties (Dependent, SetAccess = private)
        Ex
        Ey
    end
    
    methods
        
        function obj = OpticalSignal(varargin)
            obj.Name = 'OpticalSignal';
            SetVariousProp(obj, varargin{:})
        end
        
        function ex = get.Ex(obj)
            if ~isempty(obj.E)
                ex = obj.E(1,:);
            else 
                ex = [];
            end
        end
        
        function ey = get.Ey(obj)
            if ~isempty(obj.E)
                ey = obj.E(2,:);
            else
                ey = [];
            end
        end
        
        function x = copy(obj)
            x       = OpticalSignal;
            x.fc    = obj.fc;
            x.Azi   = obj.Azi;
            x.Ell   = obj.Ell;
            x.fs    = obj.fs;
        end
    end
    
end

