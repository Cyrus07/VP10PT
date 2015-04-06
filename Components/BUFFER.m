classdef BUFFER < Module
%   BUFFER v1.0, Lingchen Huang, 2015/3/16
    
    properties
        Buffer = []
        Length
    end
    properties (SetAccess = private)

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        function obj = BUFFER(varargin)
            SetVariousProp(obj, varargin{:})
        end
        
        function Input(obj, x)
            obj.Buffer = [obj.Buffer; x];
            if ~isempty(obj.Length)
                if size(obj.Buffer,1)>obj.Length
                    obj.Buffer = obj.Buffer(end-obj.Length+1:end,:);
                end
            end
        end
        
        function y = Output(obj, n)
            if nargin<2
                n = size(obj.Buffer,1);
            end
            if n > size(obj.Buffer,1)
                warning('BUFFER INSUFFICIENT');
                y = obj.Buffer;
                obj.Buffer = [];
            else
                y = obj.Buffer(1:n,:);
                obj.Buffer = obj.Buffer(n+1:end,:);
            end
        end

    end
    
end