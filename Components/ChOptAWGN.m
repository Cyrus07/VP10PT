classdef ChOptAWGN < Channel_ & Optical_
    %ChOptAWGN v1.0, Lingchen Huang, 2015/4/6
    %
    %
    %   Overlap simulation is supported.
    %   The following input types are supported,
    %   multi-polarization
    %   complex signal
    %   Noise generation seed is not to be implemented in this version.
    %
    %   Also see, Channel_
    %
    %%
    properties
        nPol                = 2
        FrameOverlapRatio   = 0
        FrameLen              = 2^12;
        
        OSNR
        % SNR     = 10;
        RandomNumberSeed
    end
    properties (Access = protected)
        rngState
        % noise
    end
    
    methods
        %%
        function obj = ChOptAWGN(varargin)
            SetVariousProp(obj, varargin{:})
            Init(obj);
        end
        %%
        function Reset(obj)
            Init(obj);
        end
        %%
        function Init(obj)
            obj.noise = BUFFER('Length', obj.FrameLen);
            obj.RandomNumberSeed = randi([1,1e9],1);
        end
        %%
        function y = Processing(obj, x)
            % AWGN
            Check(x, 'OpticalSignal');
            y = Copy(x);
            if ~obj.Active
                y.E = x.E;
                return;
            end
            if isempty(x.E)
                return;
            end
            noiseCalc(obj, x);
            y.E = x.E + obj.noise.Buffer;
        end
        %%
        function noiseCalc(obj, x)
            % get Signal-to-Noise ratio per sample
            obj.SNR = obj.OSNR - 10*log10(x.fs/12.5e9);
            signalpower = OpticalPowerMeter(x, 'W');
            noisepower = signalpower/db2pow(obj.SNR);
            Nsamp = size(x.E,1);
            
            if isempty(obj.noise.Buffer)
                % set random number generator seed
                rngCurrState = SetRandomSeed(obj.RandomNumberSeed);
                tmp = sqrt(noisepower/2/obj.nPol) .* (randn(Nsamp,obj.nPol)+1i*randn(Nsamp,obj.nPol));
                obj.noise.Input(tmp);
            else
                rngCurrState = SetrngState(obj.rngState);
                tmp = sqrt(noisepower/2/obj.nPol).*...
                    (randn(Nsamp*(1-obj.FrameOverlapRatio),obj.nPol)...
                    +1i*randn(Nsamp*(1-obj.FrameOverlapRatio),obj.nPol));
                obj.noise.Input(tmp);
            end
            % recover previous random number generator seed
            obj.rngState = SetrngState(rngCurrState);
        end
        
    end
    
end

