function [DateMarker,TimeMarker,strLogTime] = getClock()
%GETCLOCK Summary of this function goes here
%   Detailed explanation goes here
c = clock;
DateMarker = sprintf('%4.0f%02.0f%02.0f',c(1:3));
TimeMarker = sprintf('%02.0f%02.0f%02.0f',c(4:6));
strLogTime = sprintf('%02.0f:%02.0f:%02.0f',c(4:6));
end