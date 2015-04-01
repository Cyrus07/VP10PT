classdef SignalType < hgsetget 
    %SignalType v1.0, Lingchen Huang, 2015/3/16
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