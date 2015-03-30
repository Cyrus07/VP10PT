function [] = SetVariousProp( obj, varargin )
%SETVARIOUSPROP Set properties of class represented by its handle OBJ
%   Set properties of obj if and only if the property is not empty. So if
%   we want to keep the default property value of one obj, leave it as
%   empty when setting it.
%
%   Example:
%
%   SetVariousProp( obj, 'property1', value1, 'property2', value2, ...)
%
%   See Also:

%   Copyright2011 Wangdawei

CheckEvenNargin( varargin{:} )

for k = 1:2:length(varargin)
    if ~isempty(varargin{k+1})
        set( obj, varargin{k}, varargin{k+1} )
    end
end

end

function CheckEvenNargin( varargin )
%CHECKEVENNARGIN Summary of this function goes here
%   Detailed explanation goes here
moda = mod( length(varargin), 2 );

if moda
    error('CHECKEVENNARGIN::Number of inputs should be EVEN')
end

end