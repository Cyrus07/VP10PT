classdef SignalTypeElectrical < SignalType
    %SignalTpyeElectrical Summary of this class goes here
    %   Detailed explanation goes here
    properties
        Rs = []
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

