classdef EleRectPulse < Electrical_
    %EleRectPulse v1.0, Lingchen Huang, 2015/3/16
    properties
        SymbolRate      = 28e9;
        SamplingRate    = 28e9*8;
    end
    properties (Access = private)
        SamplePerSymbol
    end
    properties (GetAccess = protected)
        Input
    end
    properties (SetAccess = protected)
        Output
    end
    methods
        %%
        function obj = EleRectPulse(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Processing(obj)
            for n = 1:length(obj.Input)
                obj.Output{n} = SignalTypeElectrical;
                obj.Output{n}.fs = obj.SamplingRate;
                obj.Output{n}.Rs = obj.SymbolRate;
                if ~obj.Active
                    obj.Output{n}.E = obj.Input{n};
                    continue
                end
                if isempty(obj.Input{n})
                    continue
                end
                syms = obj.Input{n};
                syms = reshape(syms, 1, []);
                obj.SamplePerSymbol = obj.SamplingRate / obj.SymbolRate;
                pulses = repmat( syms, obj.SamplePerSymbol, 1 );
                obj.Output{n}.E = pulses(:);
            end
        end
    end
    
end

