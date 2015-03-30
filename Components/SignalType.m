classdef SignalType < hgsetget 
    %SIGNALTYPE Summary of this class goes here
    %   Detailed explanation goes here
    %
    %%
    properties
        E  = []
        fs = []
    end
    
    properties (SetAccess = protected)
        Name
    end
    methods
        %%
        function obj = SignalType(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Check(obj, varargin)
            flag = 1;
            for n = 1:length(varargin)
                if strcmpi(obj.Name, varargin{n})
                    flag = 0;
                end
            end
            if flag
                warning('CheckSignalType::incorrect input signal type..')
            end
        end
    end
    methods (Abstract)
        Copy(obj)
    end
    
end