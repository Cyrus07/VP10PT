classdef DSP_ < Module
%   DSP v1.0, Lingchen Huang, 2015/6/8
    
    properties
        sps
        mn
        Rs
        nPol
    end
    
    methods (Abstract)
        Init(obj)
        Processing(obj)
        Reset(obj)
    end
    
end