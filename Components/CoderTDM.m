classdef CoderTDM < Coder_
    %CoderTDM v1.0, Lingchen Huang, 2015/3/16
    %
    %
    %   This module do not implement advanced modulation, only argument
    %   passing is realized.
    %
    %   Also see, Coder_
    %
    %
    %%
    properties
%         nPol
%         FrameLen
%         FrameOverlapLen
%         mn
    end
    properties (SetAccess = protected)
%         OverlapBuf
    end
    
    methods
        %%
        function obj = CoderTDM(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            Init(obj);
        end
        %%
        function Init(obj)
            for n = 1:obj.nPol
                obj.OverlapBuf{n} = BUFFER('Length', obj.FrameLen);
            end
        end
        %%
        function y = Processing(obj, x)
            for n = 1:length(x)
                % push in buffer
                obj.OverlapBuf{n}.Input(x{n});
                % read buffer
                y{n} = obj.OverlapBuf{n}.Buffer;
            end
        end
        %%
        function bits_number = DemandBitsNumPerPol(obj)
            bits_number(1) = obj.FrameLen * log2(obj.mn);
            bits_number(2) = (obj.FrameLen - obj.FrameOverlapLen) * log2(obj.mn);
        end
    end
end
