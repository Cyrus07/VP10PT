classdef ActiveModule < Module
    %ActiveModule Summary of this class goes here
    %   Detailed explanation goes here
    %   v1.0, Lingchen Huang, 2015/3/16

    methods (Abstract)
        % clear Input, Output and Buffer
        Init(obj)
        Reset(obj)
    end
end
