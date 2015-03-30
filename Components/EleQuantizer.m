classdef EleQuantizer < Electrical_
    % http://en.wikipedia.org/wiki/Quantization_(signal_processing)
    % mid-riser uniform quantizers
    
    properties
        Resolution = 6
        type = 'mid-tread'
    end
    properties (GetAccess = protected)
        Input
    end
    properties (SetAccess = protected)
        Output
    end
    
    methods
        %%
        function obj = EleQuantizer(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Processing(obj)
            for n = 1:length(obj.Input)
                if isobject(obj.Input{n})
                    Check(obj.Input{n}, 'ElectricalSignal');
                    obj.Output{n} = Copy(obj.Input{n});
                    inputVec = obj.Input{n}.E;
                elseif isnumeric(obj.Input{n})
                    obj.Output{n} = [];
                    inputVec = obj.Input{n};
                end
                if ~obj.Active
                    obj.Output{n}.E = inputVec;
                    continue
                end
                if isempty(inputVec)
                    continue
                end
                rOutput = obj.quantize(real(inputVec));
                iOutput = obj.quantize(imag(inputVec));
                if isobject(obj.Output{n})
                    obj.Output{n}.E = rOutput + 1i * iOutput;
                elseif isnumeric(obj.Output{n})
                    obj.Output{n} = rOutput + 1i * iOutput;
                end
            end
        end
        %%
        function yVec = quantize(obj,xVec)
            if (max(xVec)-min(xVec))>0
                tread = (max(xVec)-min(xVec))/(round(2^obj.Resolution)-1);
                switch obj.type
                    case 'mid-riser'
                        yVec = tread*(round(xVec/tread)+1/2);
                    case 'mid-tread'
                        yVec = tread*sign(xVec).*(round(abs(xVec)/tread+1/2)-1/2);
                    otherwise
                        
                end
            else
                yVec = xVec;
            end
        end
    end
    
end