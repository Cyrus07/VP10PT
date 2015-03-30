classdef EleSampler < Electrical_
    %EleSampler Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SamplingRate    = 28e9;
        SamplingPhase   = 1;
    end
    properties (GetAccess = protected)
        Input
    end
    properties (SetAccess = protected)
        Output
    end
    methods
        function obj = EleSampler(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Processing(obj)
            npol = length(obj.Input);
            if isempty(obj.SamplingRate)
                obj.SamplingPhase = obj.Input{1}.fs;
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
                Check(obj.Input{n}, 'ElectricalSignal');
                obj.Output{n} = Copy(obj.Input{n});
                if isempty(obj.Input{n}.E)
                    continue
                end
                
                head = obj.SamplingPhase(n);
                DivSamplingRate = obj.Input{n}.fs ...
                    / obj.SamplingRate(n);
                ReSamplingRate = obj.SamplingRate(n) * round(DivSamplingRate);
                jump = ReSamplingRate / obj.SamplingRate(n);
                
                [num, den] = numden(sym(ReSamplingRate/obj.Input{n}.fs));
                rx = resample(obj.Input{n}.E, double(num), double(den));
                
                obj.Output{n}.E = rx(head:jump:end);
                obj.Output{n}.fs = obj.SamplingRate(n);
            end
        end
    end
    
end

