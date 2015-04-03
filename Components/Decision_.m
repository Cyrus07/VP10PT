classdef Decision_ < ActiveModule
    %Decision_ v1.0, Lingchen Huang, 2015/3/16
    %
    %
    %   hMod is modulation handle defined at Tx,
    %   hDec is the corresponding de-modulation handle pre-defined by
    %   Matlab
    %   Two type of output is offered, namely, integer symbol and bit
    %   sequence.
    %
    %   Also see, ModulateQAM
    %
    %
    %%
    properties
        nPol
        hMod
        RefSym      = []
        DispEVM     = false
    end
    properties (SetAccess = protected)
        EVM
    end
    properties (Access = private)
        hDec
        RefBuf
    end
    
    methods
        function obj = Decision_(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            obj.EVM = [];
            Init(obj);
        end
        %%
        function Init(obj)
            for n = 1:obj.nPol
                obj.RefBuf{n} = BUFFER;
            end
            SetDecHandle(obj);
        end
        %%
        function [yBit, yInt] = Processing(obj, x)
            for n = 1:obj.nPol
                if isempty(x{n})
                    yBit{n} = [];
                    yInt{n} = [];
                    continue;
                end
                inVec = x{n};
                % both "integer" and "bit" output type is implemented
                yInt{n} = obj.hDec.demodulate(inVec);
                hDecBit = copy(obj.hDec);
                hDecBit.OutputType = 'bit';
                yBit{n} = hDecBit.demodulate(inVec);
                if isempty(obj.RefBuf{n}.Buffer)
                    obj.RefBuf{n}.Input(obj.hMod.modulate(yBit{n}));
                end
            end
            %
            if ~isempty(obj.RefSym)
                for n = 1:obj.nPol
                    obj.RefBuf{n}.Input(obj.RefSym{n});
                    obj.RefSym{n} = [];
                end
            end
            ShowEVM(obj, x);
        end
        %%
        function SetDecHandle(obj)
            % de-modulation is implemented corresponding to transmitter
            % modulation format.
            switch lower(obj.hMod.Type)
                case 'qam modulator'
                    obj.hDec = modem.qamdemod;
                    obj.hDec.PhaseOffset = obj.hMod.PhaseOffset;
                case 'psk modulator'
                    obj.hDec = modem.pasdemod;
                    obj.hDec.PhaseOffset = obj.hMod.PhaseOffset;
                case 'pam modulator'
                    obj.hDec = modem.pamdemod;
                otherwise
            end
            obj.hDec.M = obj.hMod.M;
            obj.hDec.SymbolOrder = obj.hMod.SymbolOrder;
            obj.hDec.OutputType = 'integer';
        end
        %%
        function ShowEVM(obj, x)
            if obj.DispEVM
                if isempty(x{obj.DispEVM})
                    obj.EVM = [];
                    return;
                end
                N = (sqrt(obj.hMod.M)-1)^2;
                len = length(x{n});
                obj.EVM ...
                    = sqrt(abs(x{n}-obj.RefBuf{n}.Output(len)).^2/N);
                len = length(obj.EVM);
                npartion = 16;
                dlen = floor(len/npartion);
                evm = obj.EVM(1:npartion*dlen);
                evm1 = reshape(evm, dlen, []);
                evm1 = rms(evm1,1);
                x = (obj.Count-1)*npartion+1 : obj.Count*npartion;
                figure(888);
                scatter(x, evm1,'ro')
                hold on;
                grid on;
            end
        end
    end
end
