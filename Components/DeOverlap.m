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
        nPol                = 1
        FrameOverlapRatio   = 0
    end
    properties (Access = private)
        FrameBuf
    end
    
    methods
        %%
        function obj = DeOverlap(varargin)
            SetVariousProp(obj, varargin{:})
            Init(obj);
        end
        %%
        function Reset(obj)
            Init(obj);
        end
        %%
        function Init(obj)
            for n = 1:obj.nPol
                obj.FrameBuf{n} = BUFFER;
            end
        end
        %%
        function y = Processing(obj, x)
            for n = 1:length(x)
                if isobject(x{n})
                    Check(x{n}, 'ElectricalSignal');
                    inputVec = x{n}.E;
                elseif isnumeric(x{n})
                    inputVec = x{n};
                end
                % This module must be Active
                if isempty(inputVec)
                    y{n} = [];
                    continue
                end
                if isempty(obj.FrameBuf{n}.Buffer)
                    obj.FrameBuf{n}.Input(inputVec);
                    y{n} = obj.FrameBuf{n}.Output(length(inputVec)*obj.FrameOverlapRatio/2);
                    continue;
                end
                if ~logical(obj.FrameOverlapRatio)
                    idx_offset1 = 0;
                    idx_offset2 = 0;
                else
                    CorrLen = length(x{n}.E) * obj.FrameOverlapRatio;
                    rx1 = obj.FrameBuf{n}.Buffer(end-CorrLen+1:end);
                    rx2 = x{n}.E(1:CorrLen);
                    % do correlation
                    xcorrel = abs(ifft(fft(conj(flipud(rx1))).*fft(rx2)))...
                        /(rx2.' * rx2);
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
                y{n} = buf(1:end-idx_offset1);
            end
        end
    end
end
