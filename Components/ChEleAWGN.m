classdef ChEleAWGN < Channel_
    %ChEleAWGN v1.0, Lingchen Huang, 2015/3/16
    %
    %
    %   Overlap simulation is supported.
    %   The following input types are supported,
    %   multi-input
    %   complex signal
    %   Noise generation seed is not to be implemented in this version.
    %
    %   Also see, Channel_
    %
    %%
    properties
        nPol                = 1
        FrameOverlapRatio   = 0
        BufLen              = 2^12;
    end
    properties
        %         SNR     = 10;
    end
    properties (Access = protected)
        %         noise
    end
    
    methods
        %%
        function obj = ChEleAWGN(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            Init(obj);
        end
        %%
        function Init(obj)
            for n = 1:obj.nPol
                obj.noise{n} = BUFFER('Length', obj.BufLen);
            end
        end
        %%
        function y = Processing(obj, x)
            % AWGN
            for n = 1:obj.nPol
                Check(x{n}, 'ElectricalSignal');
                y{n} = Copy(x{n});
                if ~obj.Active
                    y{n}.E = x{n}.E;
                    continue;
                end
                if isempty(x{n}.E)
                    continue;
                end
                noiseCalc(obj, x, n);
                y{n}.E = x{n}.E + obj.noise{n}.Buffer;
            end
        end
        %%
        function noiseCalc(obj, x, n)
            %
            ps = x{n}.E(:)' * x{n}.E(:) ...
                / size(x{n}.E,1);
            pn = ps / db2pow(obj.SNR);
            len = length(x{n}.E);
            %
            if ~isempty(obj.noise{n}.Buffer)
                len = len * (1 - obj.FrameOverlapRatio);
            end
            %
            if isreal(x{n}.E(1))
                noiseVec = sqrt(pn) * randn(len,1);
            else
                noiseVec = sqrt(pn/2) * ...
                    (randn(len,1) + 1i * randn(len,1));
            end
            obj.noise{n}.Input(noiseVec);
        end
        
    end
    
end

