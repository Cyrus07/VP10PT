function OutCst = PhaseOffsetEstimate(InCst)
% Phase Recovery for QPSK and 16QAM
% 4-power
tmpCST = InCst.*exp(1i*pi/4);
phase = angle(sum(reshape(tmpCST,1,[]).^4))/4;
OutCst = InCst*exp(-1i*phase);
end