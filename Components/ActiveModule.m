classdef ActiveModule < Module
    %ActiveModule Summary of this class goes here
    %   Detailed explanation goes here
    %   v1.0, Lingchen Huang, 2015/3/16

    properties (SetAccess = protected)
        Count   = 0
    end
    methods (Abstract)
        % clear Input, Output and Buffer
        Reset(obj)
    end
end
