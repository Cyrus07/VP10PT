function c = constellation(mn)
%
%   Give the standard form of constellations
%
%   Example
%
%   See Also
%
%   Copyright2012

h = modem.qammod('M',mn);

cr = h.Constellation;

c = cr(:);