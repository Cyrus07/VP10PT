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
%         FrameLen
%         FrameOverlapLen
%         mn
    end
    properties (GetAccess = protected)
%         Input
    end
    properties (SetAccess = protected)
%         OverlapBuf
%         Output
    end
    
    methods
        %%
        function obj = CoderTDM(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            obj.Count       = 0;
            obj.Input       = [];
            obj.Output      = [];
            obj.OverlapBuf  = [];
        end
        %%
        function Processing(obj)
            obj.Count = obj.Count + 1;
            if obj.Count == 1
                for n = 1:length(obj.Input)
                    obj.OverlapBuf{n} = BUFFER('Length', obj.FrameLen);
                end
            end
            for n = 1:length(obj.Input)
                % push in buffer
                obj.OverlapBuf{n}.Input(obj.Input{n});
                % read buffer
                obj.Output{n} = obj.OverlapBuf{n}.Buffer;
            end
        end
        %%
        function bits_number = DemandBitsNumPerPol(obj)
            bits_number(1) = obj.FrameLen * log2(obj.mn);
            bits_number(2) = (obj.FrameLen - obj.FrameOverlapLen) * log2(obj.mn);
        end
    end
end
