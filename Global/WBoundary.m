classdef WBoundary
    %WBOUNDARY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        OverlapLength = 64
        
        Overlap     = struct('SymReference',[], 'BitReference',[])
        CmaTaps     = struct('H1',[],'H2',[])
        CpePhase    = [0,0]
        
        LaserPhase  = []
        BinaryData  = []
        
        Plot_H1     = []
        Plot_H2     = []
    end
    
    methods
    end
    
end