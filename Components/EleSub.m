function [ y ] = EleSub( x1,x2 )
%ELECTRICALSUB Summary of this function goes here
%   Note that every two inputs generate one output

Check(x2, 'ElectricalSignal')
Check(x1, 'ElectricalSignal')

y = Copy(x1);

y.E = x1.E - x2.E;

end

