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
    properties (GetAccess = protected)
%         Input        
    end
    properties (SetAccess = protected)
%         Output
%         h
    end
    methods
        function obj = ModulateQAM(varargin)
            SetVariousProp(obj, varargin{:})
        end
        function Reset(obj)
            obj.Count = 0;
        end
        %%
        function Processing(obj)
            obj.Count = obj.Count + 1;
            if obj.Count == 1;
                SetModHandle(obj);
            end
            for n = 1:length(obj.Input)
                obj.Output{n} = obj.h.modulate(obj.Input{n});
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
