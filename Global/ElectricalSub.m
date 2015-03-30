function [ y ] = ElectricalSub( x1,x2 )
%ELECTRICALSUB Summary of this function goes here
%   Note that every two inputs generate one output

CheckSignalType('ElectricalSignal', x1,x2)

y = copy(x1);

y.E = x1.E - x2.E;

end

