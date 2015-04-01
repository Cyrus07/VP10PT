classdef ElectricalDriver < SuperClassHandle
    
    properties
        SamplingRate
        Resolution
        QuanActive
        RiseTime
        Bandwidth
    end
    properties (SetAccess = private)
        Quan
        Rect
        Guass
        Bessel
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        function obj = ElectricalDriver(varargin)
            SetVariousProp(obj, varargin{:})
        end
        
        function reset(obj,Fs)
            sps = obj.SamplingRate / Fs;
            obj.Quan = Quantizer('Resolution', obj.Resolution,...
                'Active', obj.QuanActive);
            obj.Rect = RectangleForm('SamplingRate', obj.SamplingRate,...
                'SamplePerSymbol',sps);
            obj.Guass = Gaussian('SamplePerSymbol',sps,...
                'RiseTime', obj.RiseTime);
            obj.Bessel = Bessel5Filt('Bandwidth', obj.Bandwidth,...
                'Active',logical(sps-1));
        end
        
        function yElField = Output(obj, dataVec, Fs)
            reset(obj,Fs)
            
            if length(dataVec)>1
                Q = obj.Quan.Output(dataVec);
                R = obj.Rect.filter(Q);
                B = obj.Bessel.filter(R);
                yElField = B;
            else
                error('NOT ENOUGH SIGNAL INPUT');
            end
        end
        
    end
    
end

