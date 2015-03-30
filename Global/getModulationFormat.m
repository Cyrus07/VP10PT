function mf_name = getModulationFormat( mn )
%GETMODULATIONFORMAT Summary of this function goes here
%   Detailed explanation goes here
switch mn
    case 1
        mf_name = 'ASK';
    case 2
        mf_name = 'BPSK';
    case 4
        mf_name = 'QPSK';
    case 8
        mf_name = '8PSK';
    case 16
        mf_name = '16-QAM';
    case 64
        mf_name = '64-QAM';
end