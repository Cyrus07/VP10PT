function [ varargout ] = EleAdd( varargin )
%EleAdd Summary of this function goes here
%   Note that every two inputs generate one output
for n = 1:length(varargin)
	Check(varargin{n}, 'ElectricalSignal')
end
CheckEvenNargin( varargin{:} )

for k = 1:2:length(varargin)
    x = varargin{k}.Amplitude + varargin{k+1}.Amplitude;
    varargout{(k+1)/2} = ElectricalSignal('Amplitude', x, ...
        'SamplesPerSymbol', varargin{k}.SamplesPerSymbol);
end

end

