classdef EleSampler < Electrical_
    %EleSampler v1.0, Lingchen Huang, 2015/3/16
    
    properties
        SamplingRate    = 28e9;
        SamplingPhase   = 1;
    end
    methods
        function obj = EleSampler(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function y = Processing(obj, x)
            npol = length(x);
            if isempty(obj.SamplingRate)
                obj.SamplingPhase = x{1}.fs;
            end
            if length(obj.SamplingRate) == 1
                obj.SamplingRate = obj.SamplingRate * ones(1,npol);
            end
            if isempty(obj.SamplingPhase)
                obj.SamplingPhase = 1;
            end
            if length(obj.SamplingPhase) == 1
                obj.SamplingPhase = obj.SamplingPhase * ones(1,npol);
            end
            
            for n = 1:npol
                % This module must be Active
                Check(x{n}, 'ElectricalSignal');
                y{n} = Copy(x{n});
                if isempty(x{n}.E)
                    continue
                end
                
                head = obj.SamplingPhase(n);
                DivSamplingRate = x{n}.fs ...
                    / obj.SamplingRate(n);
                ReSamplingRate = obj.SamplingRate(n) * round(DivSamplingRate);
                jump = ReSamplingRate / obj.SamplingRate(n);
                
                [num, den] = numden(sym(ReSamplingRate/x{n}.fs));
                rx = resample(x{n}.E, double(num), double(den));
                
                y{n}.E = rx(head:jump:end);
                y{n}.fs = obj.SamplingRate(n);
            end
        end
    end
    
end

