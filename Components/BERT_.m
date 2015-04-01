classdef BERT_ < ActiveModule
    %BERT_ v1.0, Lingchen Huang, 2015/3/16
    %   
    %
    %   This module simply calculate error rate, error count and bit count
    %   RefBits is the reference bit sequence generate at Transmitter.
    %   Input is the bit sequence after decision/FEC decoder.
    %   In the module, the length of RefBits and Input have to be the same.
    %
    %   Also see, SourceBinary
    %
    %
    %%
    properties
        ErrCount    = 0
        BitCount    = 0
        ErrRatio    = Inf
        ErrIdx
        RefBits
    end
    properties (GetAccess = protected)
        Input
    end
    
    methods
        %%
        function obj = BERT_(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            obj.ErrCount = [];
            obj.BitCount = [];
            obj.ErrRatio = Inf;
        end
        %%
        function Init(~)
        end
        %%
        function Processing(obj)
            % simple bit compare and error count.
            [ec, ~, Idx] = biterr(obj.Input, obj.RefBits);
            obj.ErrIdx = Idx;
            obj.ErrCount = obj.ErrCount + ec;
            obj.BitCount = obj.BitCount + length(obj.Input);
            obj.ErrRatio = obj.ErrCount / obj.BitCount;
        end
    end
end
