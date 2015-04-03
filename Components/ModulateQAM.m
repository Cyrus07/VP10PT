classdef ModulateQAM < Modulate_
    %ModulateQAM v1.0, Lingchen Huang, 2015/3/16
    %   
    %
    %   Modulation handle uses matlab codem.qam.
    %
    %   Also see Modulate_
    %
    %
    %%
    properties
        mn  = 4
        map = 'Gray'
    end
    properties (SetAccess = protected)
%         h
    end
    methods
        function obj = ModulateQAM(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Init(obj)
            SetModHandle(obj);
        end
        %%
        function y =Processing(obj, x)
            for n = 1:length(x)
                y{n} = obj.h.modulate(x{n});
            end
        end
        %%
        function SetModHandle(obj)
            % standard QAM modulation is initialized.
            obj.h = modem.qammod;
            obj.h.M = obj.mn;
            obj.h.SymbolOrder = lower(obj.map);
            obj.h.InputType = 'bit';
        end
    end
end
