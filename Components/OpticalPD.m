classdef OpticalPD < Optical_ & ActiveModule
    %OpticalPD Summary of this class goes here
    %   Three important factors of a photodetector: 
    %   bandwidth, responsivity and dark current. 
    %   For a good PD, the dark current should be I_d < 10nA.
    %   Noise mechanisms:
    %   Shot noise: a stationary random process with Poisson statistics,
    %   the variance of shot noise is equivalent to the zero-delay
    %   autocorrelation function of I_s which can be related directly with
    %   the spectral density by Wiener-Khinchin theorem.
    
    properties
        OverlapRatio
        BufferLength
        Responsivity    = 1.0
        Bandwidth       = 40e9
        LPF             = 0
        AddNoise = 0
    end
    
    properties (SetAccess = private)
        DarkCurrent     = 10e-9
        Temperature = 300
        LoadResistance = 50
        NoiseTh
        NoiseSh
        ElectricalLPF   = [];
    end
    
    methods
        function obj = OpticalPD(varargin)
            SetVariousProp(obj, varargin{:})
            Init(obj)
        end
        
        function Init(obj)
            obj.ElectricalLPF = EleLPF('Bandwidth', obj.Bandwidth, 'Active', obj.LPF);
            obj.NoiseTh = BUFFER('Length', obj.BufferLength);
            obj.NoiseSh = BUFFER('Length', obj.BufferLength);
        end
        
        function Reset(obj)
            Init(obj)
        end
        
        function y = Processing(obj, x)
            a = x.E;
            Is = obj.Responsivity .* sum(a.*conj(a),2);
            Nsamp = length(Is);
            
            Id = obj.DarkCurrent;
            
            if obj.AddNoise
                k_B = obj.BoltzmannK;
                T = obj.Temperature;
                R = obj.LoadResistance;
                B = x.fs;
                ThermalNoise = sqrt( 4*k_B*T/R * B );
                if isempty(obj.NoiseTh.Buffer)
                    tmp = normrnd(0,ThermalNoise,[Nsamp, 1]);
                    obj.NoiseTh.Input(tmp);
                else
                    tmp = normrnd(0,ThermalNoise,[Nsamp*(1-obj.OverlapRatio), 1]);
                    obj.NoiseTh.Input(tmp);
                end
            else
                obj.NoiseTh.Input(zeros(Nsamp, 1));
            end
            
            if obj.AddNoise
                q = obj.ElectronC;
                B = x.fs;
                if isempty(obj.NoiseSh.Buffer)
                    ShotNoise = sqrt( 2*q*(Is + Id) * B );
                    tmp = normrnd(0,ShotNoise,[Nsamp, 1]);
                    obj.NoiseSh.Input(tmp);
                else
                    ShotNoise = sqrt( 2*q*(Is(Nsamp*(1-obj.OverlapRatio)+1:Nsamp) + Id) * B );
                    tmp = normrnd(0,ShotNoise,[Nsamp*(1-obj.OverlapRatio), 1]);
                    obj.NoiseSh.Input(tmp);
                end
            else
                obj.NoiseSh.Input(zeros(Nsamp, 1));
            end
            
            b = obj.LoadResistance * (Is + Id + obj.NoiseTh.Buffer + obj.NoiseSh.Buffer);
            
            V{1} = SignalTypeElectrical('E',b,'fs',x.fs,'Rs',x.Rs);
            y = obj.ElectricalLPF.Processing(V);
        end
    end
    
end