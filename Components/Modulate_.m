classdef Modulate_ < ActiveModule
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
    properties (GetAccess = protected)
        Input        
    end
    properties (SetAccess = protected)
        Output
        h
    end
    methods
        %%
        function obj = Modulate_(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Reset(obj)
            obj.Count = 0;
        end
        %%
        function Processing(obj)
            obj.Count = obj.Count + 1;
            if obj.Count == 1
                SetModHandle(obj);
            end
            obj.Output = obj.h.modulate(obj.Input);
        end
        %%
        function SetModHandle(obj)
            % standard BPSK modulation is initialized.
            obj.h = modem.pammod;
            obj.h.M = 2;
        end
    end
end
