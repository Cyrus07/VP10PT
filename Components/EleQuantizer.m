classdef EleQuantizer < Electrical_
    %EleQuantizer v1.0, Lingchen Huang, 2015/3/16
    % http://en.wikipedia.org/wiki/Quantization_(signal_processing)
    % mid-riser uniform quantizers
    
    properties
        Resolution = 6
        type = 'mid-tread'
    end
    
    methods
        %%
        function obj = EleQuantizer(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function y = Processing(obj, x)
            for n = 1:length(x)
                if isobject(x{n})
                    Check(x{n}, 'ElectricalSignal');
                    y{n} = Copy(x{n});
                    inputVec = x{n}.E;
                elseif isnumeric(x{n})
                    y{n} = [];
                    inputVec = x{n};
                end
                if ~obj.Active
                    y{n}.E = inputVec;
                    continue
                end
                if isempty(inputVec)
                    continue
                end
                rOutput = obj.quantize(real(inputVec));
                iOutput = obj.quantize(imag(inputVec));
                if isobject(y{n})
                    y{n}.E = rOutput + 1i * iOutput;
                elseif isnumeric(y{n})
                    y{n} = rOutput + 1i * iOutput;
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