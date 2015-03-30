function [y] = optPowerAmp( x, power )
%OPTPOWERAMP Summary of this function goes here
%   Detailed explanation goes here

y = copy(x);

a = optPowerMeter(x);

y.E = x.E.* sqrt(power/a);