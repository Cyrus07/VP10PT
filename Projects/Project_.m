classdef Project_ < Module
    %Project_ v1.0, Lingchen Huang, 2015/3/16

    methods (Abstract)
        % clear Input, Output and Buffer
        Init(obj)
        Processing(obj)
        Reset(obj)
    end
end
