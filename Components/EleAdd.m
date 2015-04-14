function [ varargout ] = EleAdd( varargin )
%ELECTRICALADD Summary of this function goes here
%   Note that every two inputs generate one output
CheckSignalType('ElectricalSignal', varargin{:})
CheckEvenNargin( varargin{:} )

for k = 1:2:length(varargin)
    x = varargin{k}.Amplitude + varargin{k+1}.Amplitude;
    varargout{(k+1)/2} = ElectricalSignal('Amplitude', x, ...
        'SamplesPerSymbol', varargin{k}.SamplesPerSymbol);
end

end

