classdef SourceBinarys < Subsystem_
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
        function y = Processing(obj)
            obj.RefMsg = [];
            for n = 1 : obj.nSource
                y{n} = obj.BinarySource{n}.Processing;
                obj.RefMsg{n} = obj.BinarySource{n}.MsgBuffer.Output;
            end
        end
    end
end

