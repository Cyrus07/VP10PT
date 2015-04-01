classdef SourceBinarys < ActiveModule
    %SourceBinarys v1.0, Lingchen Huang, 2015/3/16
    %
    %
    %
    %   Also see, SourceBinary
    %
    %
    %%
    properties
        nSource     = 1
        % SourceBinary
        BitsType 	 % PRBS, Random, UserDef
        BitseqLen
        PRBSOrder
        UserDefined
        FECType
    end
    
    properties (SetAccess = private)
        Output
        RefMsg
        BinarySource
    end
    
    methods
        %%
        function obj = SourceBinarys(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            obj.Output       = [];
            obj.RefMsg    = [];
            Init(obj);
        end
        %%
        function Init(obj)
            for n = 1 : obj.nSource
                obj.BinarySource{n} = SourceBinary(...
                    'BitsType', obj.BitsType,...
                    'BitseqLen', obj.BitseqLen,...
                    'PRBSOrder', obj.PRBSOrder,...
                    'UserDefined', obj.UserDefined,...
                    'FECType', obj.FECType);
                Init(obj.BinarySource{n});
            end
        end
        %%
        function Processing(obj)
            obj.RefMsg = [];
            for n = 1 : obj.nSource
                Processing(obj.BinarySource{n});
                obj.Output{n} = obj.BinarySource{n}.Output;
                obj.RefMsg{n} = obj.BinarySource{n}.MsgBuffer.Output;
            end
        end
    end
end

