classdef EleRectPulse < Electrical_
    %EleRectPulse v1.0, Lingchen Huang, 2015/3/16
    properties
        SymbolRate      = 28e9;
        SamplingRate    = 28e9*8;
    end
    properties (Access = private)
        SamplePerSymbol
    end
    methods
        %%
        function obj = EleRectPulse(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function y = Processing(obj, x)
            for n = 1:length(x)
                y{n} = SignalTypeElectrical;
                y{n}.fs = obj.SamplingRate;
                y{n}.Rs = obj.SymbolRate;
                if ~obj.Active
                    y{n}.E = x{n};
                    continue
                end
                if isempty(x{n})
                    continue
                end
                syms = x{n};
                syms = reshape(syms, 1, []);
                obj.SamplePerSymbol = obj.SamplingRate / obj.SymbolRate;
                pulses = repmat( syms, obj.SamplePerSymbol, 1 );
                y{n}.E = pulses(:);
            end
        end
    end
    
end

