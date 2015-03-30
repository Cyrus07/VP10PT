function delta2 = MCRB_tau(dB_osnr,Rs, BLT, rolloff)
% MCRB of tau
%
% Example
%
% See Also

Xi = 1/12 + rolloff^2*(1/4-2/pi/pi);

OSNR            = 10.^(dB_osnr/10);
EsNo            = OSNR * 12.5e9 / Rs;
EsNo_db         = 10 * log10(EsNo);

delta2           = BLT / 4/pi/pi / Xi ./(EsNo);