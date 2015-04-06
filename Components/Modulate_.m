classdef Modulate_ < Module
    %Modulate_ v1.0, Lingchen Huang, 2015/3/16
    %
    %
    %   This module applies digital modulation for bit sequence.
    %   Modulation handle uses matlab codem.pam.
    %
    %   Also see ModulateQAM
    %
    %
    %%
    properties (SetAccess = protected)
        h
    end
    methods
        %%
        function obj = Modulate_(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Init(obj)
            SetModHandle(obj);
        end
        %%
        function y = Processing(obj, x)
            y = obj.h.modulate(x);
        end
        %%
        function SetModHandle(obj)
            % standard BPSK modulation is initialized.
            obj.h = modem.pammod;
            obj.h.M = 2;
        end
    end
end
