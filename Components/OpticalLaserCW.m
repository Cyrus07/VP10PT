classdef OpticalLaserCW < Optical_ & ActiveModule
    %OpticalLaserCW v1.0, Lingchen Huang, 2015/4/3
    %   The phase noise can be modeled as a Wiener process which has the
    %   following property:
    %   W(t) = W(t) - W(0) ~ N(0,t)
    %   where N stands for Normal Distribution
    
    properties
        OverlapRatio
        BufferLength
        SamplingRate        = 28e9
        CenterFrequency 	= 193.1e12
        OutputPower         = 10    % [dBm]
        Linewidth           = 0
        InitialPhase        = 0
        Azimuth             = 45
        Ellipticity         = 0.0
        % simulation
        RandomNumberSeed
    end
    properties (SetAccess = private)
        PC
        rngState
        Phase
    end
    
    methods 
        function obj = OpticalLaserCW(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            Init(obj);
        end
        %%
        function Init(obj)
            if isemtpy(obj.RandomNumberSeed)
                obj.RandomNumberSeed = randi([1,1e9],1);
            end
            obj.PC = OpticalPolRttr('Azimuth', obj.Azimuth, ...
                'Ellipticity', obj.Ellipticity);
            obj.Phase = BUFFER('Length', obj.BufferLength);
        end
        %% 
        function cwLaser = Processing(obj, numSamp)
            
            % phase_noise variance
            pn_var = 2*pi*obj.Linewidth/obj.SamplingRate;
            
            obj.Phase.Length = numSamp;
            if isempty(obj.Phase.Buffer)
                % set random number generator seed
                rngCurrState = SetRandomSeed(obj.RandomNumberSeed);
                phase = obj.InitialPhase + ...
                    [0; cumsum(normrnd(0,sqrt(pn_var),numSamp-1,1))];
                obj.Phase.Input(phase);
            else
                rngCurrState = SetrngState(obj.rngState);
                phase = obj.Phase.Buffer(numSamp) ...
                    + cumsum(normrnd(0,sqrt(pn_var),numSamp*(1-obj.OverlapRatio),1));
                obj.Phase.Input(phase);
            end
            % recover previous random number generator seed
            obj.rngState = SetrngState(rngCurrState);
            
            % laser on
            cwLaser = sqrt(db2pow(obj.OutputPower) * 1E-3)...
                .* exp(1j*obj.Phase.Buffer);
            
            % generate a x polarized light
            cwLaser = OpticalSignal('E',[cwLaser, zeros(size(cwLaser))],...
                'fc',obj.CenterFrequency,'fs',obj.SamplingRate);
            
            % control the polarization
            cwLaser = obj.PC.Output(cwLaser);
            
            optPowerMeter(cwLaser,1);
        end     

    end
end