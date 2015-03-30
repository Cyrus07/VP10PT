function [] = CheckInputSize( size, value )
%CHECKINPUTSIZE Summary of this function goes here
%   Detailed explanation goes here
if size ~= value
    error(sprintf('incorrect input size..\nINPUT:%d\nNeed:%d',size,value));
end
end

