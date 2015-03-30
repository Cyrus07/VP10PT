classdef FECDecoder < Module
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
            obj.Count       = 0;
            obj.Rx          = [];
            obj.Input       = [];
            obj.Output      = [];
            obj.FECCodeLen  = [];
        end
        %%
        function Processing(obj)
            obj.Count = obj.Count + 1;
            if obj.Count == 1
                obj.Rx = BUFFER;
            end
            % This module must be Active
            if obj.Count == 1
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
            end
            obj.Rx.Input(obj.Input);
            obj.Output = [];
            while length(obj.Rx.Buffer) >= obj.FECCodeLen
                CodeWord = obj.Rx.Output(obj.FECCodeLen);
                MsgWord = obj.Decode(CodeWord);
                obj.Output = [obj.Output; MsgWord];
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
