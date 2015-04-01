classdef FECDecoders < ActiveModule
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
    properties (GetAccess = protected)
        Input
    end
    properties (SetAccess = protected)
        Output
    end
    
    methods
        %%
        function obj = FECDecoders(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            obj.Input   = [];
            obj.Output  = [];
            Init(obj);
        end
        %%
        function Processing(obj)
            for n = 1:obj.nPol
                if isempty(obj.Input{n})
                    obj.Output{n} = [];
                    continue;
                end
                obj.FEC{n}.Input = obj.Input{n};
                Processing(obj.FEC{n});
                obj.Output{n} = obj.FEC{n}.Output;
            end
        end
        %%
        function Init(obj)
            for n = 1:obj.nPol
                obj.FEC{n} = FECDecoder('FECType', obj.FECType);
                Init(obj.FEC{n});
            end
        end
    end
end
