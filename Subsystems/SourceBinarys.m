classdef SourceBinarys < ActiveModule
    %SourceMultiple v1.0, Lingchen Huang, 2015/3/16
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
        MsgBuffer
        BinarySource
    end
    
    methods
        %%
        function obj = SourceBinarys(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            obj.Count        = 0;
            obj.Output       = [];
            obj.MsgBuffer    = [];
            obj.BinarySource = [];
        end
        %%
        function Processing(obj)
            obj.Count = obj.Count + 1;
            Init(obj);
            for n = 1 : obj.nSource
                obj.BinarySource{n}.Processing();
                obj.Output{n} = obj.BinarySource{n}.Output;
                obj.MsgBuffer{n} = obj.BinarySource{n}.MsgBuffer.Output;
            end
        end
        function Init(obj)
            if obj.Count == 1
                for n = 1 : obj.nSource
                    obj.BinarySource{n} = SourceBinary(...
                                'BitsType', obj.BitsType,...
                               	'BitseqLen', obj.BitseqLen,...
                               	'PRBSOrder', obj.PRBSOrder,...
                              	'UserDefined', obj.UserDefined,...
                               	'FECType', obj.FECType);
                end
            end
            obj.MsgBuffer = [];
        end

    end
end

