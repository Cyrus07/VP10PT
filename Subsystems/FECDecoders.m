classdef FECDecoders < Subsystem_
    %FECDecoders v1.0, Lingchen Huang, 2015/3/16
    %
    %
    %
    %   Also see, FECDecoder
    %
    %
    %%
    properties
        nPol
        % FECDecoder
        FECType
    end
    properties (Access = private)
        FEC
    end
    
    methods
        %%
        function obj = FECDecoders(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Init(obj)
            for n = 1:obj.nPol
                obj.FEC{n} = FECDecoder('FECType', obj.FECType);
                Init(obj.FEC{n});
            end
        end
        %%
        function Reset(obj)
            Init(obj);
        end
        %%
        function y = Processing(obj, x)
            for n = 1:obj.nPol
                if isempty(x{n})
                    y{n} = [];
                    continue;
                end
                y{n} = obj.FEC{n}.Processing(x{n});
            end
        end
    end
end
