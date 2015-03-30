classdef ChEleAWGN < Channel_
    %ChannelAWGN v1.0, Lingchen Huang, 2015/3/16
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
        FrameOverlapRatio   = 0
    end
    properties
%         SNR     = 10;
    end
    properties (Access = protected)
%         noise
    end
    properties (GetAccess = protected)
%         Input
    end
    properties (SetAccess = protected)
%         Output
    end
    
    methods
        %%
        function obj = ChEleAWGN(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            obj.Input = [];
            obj.Output = [];
            obj.noise = [];
        end
        %%
        function Processing(obj)
            obj.Count = obj.Count + 1;
            if obj.Count == 1
                for n = 1:length(obj.Input)
                    obj.noise{n} = BUFFER('Length', length(obj.Input{n}.E));
                end
            end
            % AWGN
            for n = 1:length(obj.Input)
                Check(obj.Input{n}, 'ElectricalSignal');
                obj.Output{n} = Copy(obj.Input{n});
                if ~obj.Active
                    obj.Output{n}.E = obj.Input{n}.E;
                    continue;
                end
                if isempty(obj.Input{n}.E)
                    continue;
                end
                noiseCalc(obj, n);
                obj.Output{n}.E = obj.Input{n}.E + obj.noise{n}.Buffer;
            end
        end
        %%
        function noiseCalc(obj, n)
            %
            ps = obj.Input{n}.E(:)' * obj.Input{n}.E(:) ...
                / size(obj.Input{n}.E,1);
            pn = ps / db2pow(obj.SNR);
            len = length(obj.Input{n}.E);
            %
            if ~isempty(obj.noise{n}.Buffer)
                len = len * (1 - obj.FrameOverlapRatio);
            end
            %
            if isreal(obj.Input{n}.E(1))
                noiseVec = sqrt(pn) * randn(len,1);
            else
                noiseVec = sqrt(pn/2) * ...
                    (randn(len,1) + 1i * randn(len,1));
            end
            obj.noise{n}.Input(noiseVec);
        end
        
    end
    
end

