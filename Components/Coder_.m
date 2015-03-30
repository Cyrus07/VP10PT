classdef Coder_ < ActiveModule
    %Coder_ v1.0, Lingchen Huang, 2015/3/16
    %   
    %
    %   This module applies advanced modulation, e.g. OFDM, Nyquist, etc.
    %   for digital modulated input.
    %   OverlapBuf implements overlap simulation, which outputs frames with
    %   designated overlap length, denoted by FrameOverlapLen
    %   Multi-polarisation is supported, with Input of cell(1,pol)
    %   DemandBitsNumPerPol method is to support overlap simulation. The
    %   value is usually sent to Source modules
    %   
    %   Also see, CoderTDM
    %   Also see, ChannelAWGN, FECDecOverlap for overlap simualtion.
    %   Note that, overlap simulation is started here and ended at DeOverlap
    %
    %%
    properties
        FrameLen        = 2^12
        FrameOverlapLen = 2^10
        mn              = 4
    end
    properties (GetAccess = protected)
        Input
    end
    properties (SetAccess = protected)
        OverlapBuf
        Output
    end
    
    methods (Abstract)
        % Encode symbols
        Processing(obj)
        DemandBitsNumPerPol(obj)
    end
end
