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
    
    methods
        %%
        function obj = Channel_(varargin)
            obj.SNR = 10;
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(~)
        end
        %%
        function Init(~)
        end
        %%
        function y = Processing(obj, x)
            % Only digital and electrical signal type (object) is supported
            Check(x, 'ElectricalSignal');
            y = Copy(x);
            if ~obj.Active
                y.E = x.E;
            end
            if isempty(x{n}.E)
                return;
            end
            noiseCalc(obj);
            y.E = x.E + obj.noise;
        end
        %%
        function noiseCalc(obj)
            ps = obj.Input' * obj.Input / length(obj.Input);
            pn = ps / db2pow(obj.SNR);
            obj.noise = sqrt(pn) * randn(size(obj.Input));
        end
    end
end

