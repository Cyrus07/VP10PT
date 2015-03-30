classdef DeOverlap < ActiveModule
    %DeOverlap v1.0, Lingchen Huang, 2015/3/16
    %
    %
    %   Overlap simulation is supported by FrameBuf to implement rate
    %   conversion.
    %   When new input bits is received, correlation is applied between the
    %   input and buffer data, and to discard the overlap part and join the
    %   two  sequence. Then this buffer outputs sequence to Rx buffer,
    %   prepared for DSP.
    %
    %   Also see, Coder_, ChannelAWGN for overlap simualtion
    %   Note that, overlap simulation is started at Coder_ and ended here
    %
    %
    %%
    properties
        FrameOverlapRatio   = 0
    end
    properties (Access = private)
        FrameBuf
    end
    properties (GetAccess = protected)
        Input
    end
    properties (SetAccess = protected)
        Output
    end
    
    methods
        %%
        function obj = DeOverlap(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            obj.Count = 0;
            obj.Input = [];
            obj.Output = [];
            obj.FrameBuf = [];
        end
        %%
        function Processing(obj)
            obj.Count = obj.Count + 1;
            if obj.Count == 1
                for n = 1:length(obj.Input)
                    obj.FrameBuf{n} = BUFFER;
                end
            end
            obj.Output = [];
            for n = 1:length(obj.Input)
                if isobject(obj.Input{n})
                    Check(obj.Input{n}, 'ElectricalSignal');
                    inputVec = obj.Input{n}.E;
                elseif isnumeric(obj.Input{n})
                    inputVec = obj.Input{n};
                end
                % This module must be Active
                if isempty(inputVec)
                    obj.Output{n} = [];
                    continue
                end
                if isempty(obj.FrameBuf{n}.Buffer)
                    obj.FrameBuf{n}.Input(inputVec);
                    obj.Output{n} = [];
                    continue;
                end
                if ~logical(obj.FrameOverlapRatio)
                    idx_offset1 = 0;
                    idx_offset2 = 0;
                else
                    CorrLen = length(obj.Input{n}.E) * obj.FrameOverlapRatio;
                    rx1 = obj.FrameBuf{n}.Buffer(end-CorrLen+1:end);
                    rx2 = obj.Input{n}.E(1:CorrLen);
                    % do correlation
                    xcorrel = abs(ifft(fft(conj(flipud(rx1))).*fft(rx2)))/CorrLen;
                    [maxCorr, Idx] = max(xcorrel);
                    if maxCorr<1/4
                        warning('Low Degree of Correlation');
                        plot(xcorrel);
                    end
                    if Idx < floor(CorrLen/2)
                        CorrLen = CorrLen + Idx;
                    end
                    % combine
                    idx_offset1 = round(CorrLen/2);
                    idx_offset2 = CorrLen - idx_offset1;
                end
                
                buf = obj.FrameBuf{n}.Output;
                obj.FrameBuf{n}.Input(inputVec(idx_offset2+1:end));
                obj.Output{n} = buf(1:end-idx_offset1);
            end
        end
    end
end
