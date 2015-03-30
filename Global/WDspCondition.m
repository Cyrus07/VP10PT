classdef WDspCondition < hgsetget
    %WUNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        DSP_SymbolRate
        DSP_SamplePerSymbol         = 2
        DSP_ConstellationOrder
        DSP_CenterFrequency         = 193.1e12
    end
    
    properties (Dependent, SetAccess = private)
        MF_Info
    end
    
    methods
        function minfo = get.MF_Info(this)
            minfo = getModulationFormat(this.DSP_ConstellationOrder);
        end
    end
    
    methods (Abstract)
        process(this);
    end
    
end

