classdef SignalTypeOptical < SignalType
    %OPTICALSIGNAL Summary of obj class goes here
    %   Detailed explanation goes here
    
    properties
        fc  = 193.1e12
    end
    
    properties (Dependent, SetAccess = private)
        Ex
        Ey
    end
    
    methods
        
        function obj = SignalTypeOptical(varargin)
            obj.Name = 'OpticalSignal';
            SetVariousProp(obj, varargin{:})
        end
        
        function ex = get.Ex(obj)
            if ~isempty(obj.E)
                ex = obj.E(:,1);
            else 
                ex = [];
            end
        end
        
        function ey = get.Ey(obj)
            if ~isempty(obj.E)
                ey = obj.E(:,2);
            else
                ey = [];
            end
        end
        
        function x = Copy(obj)
            x       = SignalTypeOptical;
            x.fs    = obj.fs;
            x.Rs    = obj.Rs;
            x.fc    = obj.fc;
        end
    end
    
end

