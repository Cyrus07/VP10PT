classdef BERTAsync < BERT_
    %BERTAsync v1.0, Lingchen Huang, 2015/3/16
    %
    %
    %   This module support asynchronized RefBits and Input, both bit
    %   unaglined or with different length. In the latter case, the Input
    %   bit length should be shorter than RefBits length.
    %   Async method is to deal with the asynchonization problem.
    %   For the moment, only single polarization is support.
    %
    %   Also see, BERT_
    %
    %
    %%
    properties
        nPol
        %         ErrCount    = 0
        %         BitCount    = 0
        %         ErrRatio    = Inf
        %         ErrIdx
        %         RefBits
        DispIdx = false
        DispBER = false
    end
    properties (GetAccess = protected)
        %         Input
    end
    properties (Access = protected)
        RxBuf
        RefBuf
        Count   = 0
    end
    methods
        %%
        function obj = BERTAsync(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            obj.ErrCount = [];
            obj.BitCount = [];
            obj.ErrRatio = Inf;
            Init(obj);
        end
        %%
        function Init(obj)
            for n = 1:obj.nPol
                obj.RxBuf{n} = BUFFER;
                obj.RefBuf{n} = BUFFER;
            end
        end
        %%
        function Processing(obj)
            obj.Count = obj.Count + 1;
            ec = 0;
            er = nan;
            for n = 1:obj.nPol
                obj.RefBuf{n}.Input(obj.RefBits{n});
                if isempty(obj.Input{n})
                    continue;
                end
                if isempty(obj.RxBuf{n}.Buffer)
                    obj.RxBuf{n}.Input(obj.Input{n});
                    % align obj.RxBuf and obj.RefBuf
                    Sync(obj, n);
                end
                
                Rx = obj.RxBuf{n}.Output;
                Ref = obj.RefBuf{n}.Output(length(Rx));
                [ec(n), er(n), Idx] = biterr(Rx, Ref);
                obj.ErrIdx{n} = Idx;
            end
            obj.ErrCount(obj.Count) = sum(ec);
            obj.BitCount(obj.Count) = length(obj.Input)*length(obj.Input{1});
            obj.ErrRatio(obj.Count) = mean(er);
            ShowIdx(obj);
            ShowBER(obj);
        end
        %%
        function Sync(obj, n)
            if length(obj.RefBuf{n}.Buffer) < length(obj.RxBuf{n}.Buffer)
                warning('Insufficient Reference Bits');
            end
            rxLen = length(obj.RxBuf{n}.Buffer);
            ref = obj.RefBuf{n}.Buffer(1:rxLen);
            rx = obj.RxBuf{n}.Buffer;
            xcorrel = abs(ifft(fft(conj(flipud(ref))).*fft(rx)))/rxLen;
            [maxCorr, Idx] = max(xcorrel);
            if maxCorr<1/3
                warning('Low Degree of Correlation');
                plot(xcorrel);
            end
            if Idx < floor(rxLen/2)
                obj.RxBuf{n}.Output(Idx);
            else
                obj.RefBuf{n}.Output(rxLen - Idx);
            end
        end
        %%
        function ShowIdx(obj)
            if obj.DispIdx
                figure(987);
                len = length(obj.ErrIdx{obj.DispIdx});
                npartion = 16;
                dlen = floor(len/npartion);
                Idx = obj.ErrIdx{obj.DispIdx}(1:npartion*dlen);
                Idx1 = reshape(Idx, dlen, []);
                Idx1 = sum(Idx1,1);
                x = (obj.Count-1)*npartion+1 : obj.Count*npartion;
                scatter(x, Idx1,'ro')
                hold on;
                grid on;
            end
        end
        %%
        function ShowBER(obj)
            if obj.DispBER
                figure(789);
                scatter(obj.Count, log(obj.ErrRatio(obj.Count)),'ro')
                hold on;
                grid on;
            end
        end
    end
end
