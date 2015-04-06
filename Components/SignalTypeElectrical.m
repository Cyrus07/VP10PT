classdef SignalTypeElectrical < SignalType
    %SignalTypeElectrical v1.0, Lingchen Huang, 2015/3/16
    properties
    end
    methods
        
        function obj = SignalTypeElectrical(varargin)
            obj.Name = 'ElectricalSignal';
            SetVariousProp(obj, varargin{:})
        end
        
        function x = Copy(obj)
            x       = SignalTypeElectrical;
            x.fs    = obj.fs;
            x.Rs    = obj.Rs;
        end
    end
    
end

