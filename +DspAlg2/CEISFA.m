function ce = CEISFA(ce, taps, nfft)
% W.-R. Peng, K. Takeshima, I. Morita, H. Takahashi, and H. Tanaka,
% ¡°Scattered pilot channel tracking method for PDM-COOFDM transmissions
% using polar-based intra-symbol frequency-domain average.¡±

ampCE = abs(ce);
phaseCE = unwrap(angle(ce),[],3);
clear ce;

ce(1,1) = ampCE(1,:,:).*exp(1i*phaseCE(1,:,:));

for k = 2 : taps+1
    ce(k,:,:) = mean(ampCE(2:2*k-2,:,:)).*exp(1i*mean(phaseCE(2:2*k-2,:,:)));
end

for k = taps+2 : nfft-taps
    ce(k,:,:) = mean(ampCE(k-taps:k+taps,:,:)).*exp(1i*mean(phaseCE(k-taps:k+taps,:,:)));
end

for k = nfft-taps+1 : nfft
    ce(k,:,:) = mean(ampCE(2*k-nfft:nfft,:,:))...
        .*exp(1i*mean(phaseCE(2*k-nfft:nfft,:,:)));
end

end