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
        nDecoders
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
            obj.Count   = 0;
            obj.FEC     = [];
            obj.Input   = [];
            obj.Output  = [];
        end
        %%
        function Processing(obj)
            obj.Count = obj.Count + 1;
            Init(obj);
            for n = 1:obj.nDecoders
                if isempty(obj.Input{n})
                    obj.Output{n} = [];
                    continue;
                end
                obj.FEC{n}.Input = obj.Input{n};
                obj.FEC{n}.Processing();
                obj.Output{n} = obj.FEC{n}.Output;
            end
        end
        %%
        function Init(obj)
            if obj.Count == 1
                for n = 1:obj.nDecoders
                    obj.FEC{n} = FECDecoder('FECType', obj.FECType);
                end
            end
        end
    end
end
