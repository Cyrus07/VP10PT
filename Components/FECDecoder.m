classdef FECDecoder < ActiveModule
    %FECDecoder v1.0, Lingchen Huang, 2015/3/16
    %   
    %
    %   This module FEC decode the hard/soft decisions of output bits.
    %   Several types of FEC decoder is supported as is defined at FEC
    %   encoder at SourceCodedBinary
    %   Rx is to implement rate conversion, which outputs codeword length
    %   (FECCodeLen) bit sequence for FEC decoder.
    %
    %   Also see, FECDecOverlap, SourceCodedBinary
    %
    %
    %%
    properties
        FECType     = 'None';
    end
    properties (Access = private)
        FECCodeLen
    end
    properties (GetAccess = protected)
        Input
    end
    properties (SetAccess = protected)
        Output
        Rx
    end
    
    methods
        %%
        function obj = FECDecoder(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            Init(obj);
        end
        %%
        function Init(obj)
            switch lower(obj.FECType)
                case 'rs'
                    obj.FECCodeLen = 255*8;
                case 'ldpc'
                    obj.FECCodeLen = [];
                case 'rs-ldpc'
                    obj.FECCodeLen = [];
                case 'none'
                    obj.FECCodeLen = 2^10;
            end
            obj.Rx = BUFFER;
        end
        %%
        function y = Processing(obj, x)
            % This module must be Active
            obj.Rx.Input(x);
            y = [];
            while length(obj.Rx.Buffer) >= obj.FECCodeLen
                CodeWord = obj.Rx.Output(obj.FECCodeLen);
                MsgWord = obj.Decode(CodeWord);
                y = [y; MsgWord];
            end
        end
        %%
        function y = Decode(obj, x)
            switch lower(obj.FECType)
                case 'rs'
                    codeword = bi2de(reshape(x,8,[]).');
                    msgword = FEC.rs_dec(codeword.', 255, 239);
                    y = de2bi(msgword.').';
                    y = y(:);
                case 'ldpc'
                    y = x;
                case 'rs-ldpc'
                    y = x;
                case 'none'
                    y = x;
            end
        end
    end
end
