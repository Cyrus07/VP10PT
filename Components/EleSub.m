function [ y ] = EleSub( x1,x2 )
%EleSub Summary of this function goes here

Check(x1, 'ElectricalSignal')
Check(x2, 'ElectricalSignal')

y = Copy(x1);

y.E = x1.E - x2.E;

end

