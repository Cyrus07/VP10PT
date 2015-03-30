classdef Default
    %DEFAULT Summary of this class goes here
    %   Detailed explanation goes here
   
    properties (Constant)
        CenterFrequency = 193.1e12 % Hz
        TimeWindow      = 2^14 / 4e9; % s
        SymbolRate      = 4e9  % sym/s
        SamplingRate    = 4e9  % Hz
        BitPerSymbol    = 2     % bit/sym
        PolarDiversity  = 2
    end
    
    properties (Constant)
        LightSpeed = 299792458;
        BoltzmannK = 1.381e-23;
        ElectronC  = 1.602e-19;
    end
    
    methods (Static)
        function Fs = SamplesPerSymbol()
            Fs = Default.SamplingRate / Default.SymbolRate;
        end
        function Ts = SymbolPeriod()
            Ts = 1 / Default.SymbolRate;
        end
%         function FV = FrequencyVect()
%             N = Default.TimeWindow * Default.SamplingRate;
%             n = 1 : N/2;
%             RF = Default.SamplingRate / (N-1) / 2 * (2*n-1);
%             LF = fliplr(RF) * -1.0;
%             FV = [LF,RF];
%         end
%         function TV = TimeVect()
%             ts = 1 / Default.SamplingRate;
%             TV = ts * (1:Default.TimeWindow * Default.SamplingRate);
%         end
        function FD = FolderDir()
            tmp = mfilename('fullpath');i = strfind(tmp,'\');
            FD = tmp(1:i(end));
        end
    end
end