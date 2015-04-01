classdef Channel_ < ActiveModule
    %Channel_ v1.0, Lingchen Huang, 2015/3/16
    %	
    %   
    %   This module supports Electrical signal input. Only single
    %   polarization, and real signal is support. Noise calculation is
    %   defined as noiseCalc, to generate AWGN noise 
    %
    %   Also see, ChannelAWGN
    %
    %
    %%
    properties
        SNR     = 10;
    end
    properties (Access = protected)
        noise
    end
    properties (GetAccess = protected)
        Input
    end
    properties (SetAccess = protected)
        Output
    end
    
    methods
        %%
        function obj = Channel_(varargin)
            obj.SNR = 10;
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            obj.Input = [];
            obj.Output = [];
        end
        %%
        function Init(~)
        end
        %%
        function Processing(obj)
            % Only digital and electrical signal type (object) is supported
            Check(obj.Input, 'ElectricalSignal');
            obj.Output = Copy(obj.Input);
            if ~obj.Active
                obj.Output.E = obj.Input.E;
            end
            if isempty(obj.Input{n}.E)
                return;
            end
            noiseCalc(obj);
            obj.Output.E = obj.Input.E + obj.noise;
        end
        %%
        function noiseCalc(obj)
            ps = obj.Input' * obj.Input / length(obj.Input);
            pn = ps / db2pow(obj.SNR);
            obj.noise = sqrt(pn) * randn(size(obj.Input));
        end
    end
end

