function awg(AWG)

IPaddress = strcat('TCPIP0::', AWG.IPaddress, '::inst0::INSTR');       % AWG IP address such as 'TCPIP::10.71.103.173::INSTR'
InBuffersize = AWG.InBuffersize;   % Input Buffer Size, such as 4e6 (not sure the unit)
OutBuffersize = AWG.OutBuffersize;   % OutPut Buffer Size, such as 4e6 
Timeout = AWG.Timeout;         % Time Out in Second, if no response within this duration , function returns
%% Interface configuration and instrument connection
% Find a VISA-TCPIP object.
Obj = instrfind('Type', 'visa-tcpip', 'RsrcName', IPaddress , 'Tag', '');
% obj1 = instrfind('Type', 'visa-tcpip', 'RsrcName', 'TCPIP0::192.168.201.109::inst0::INSTR', 'Tag', '');

% Create the VISA-TCPIP object if it does not exist
% otherwise use the object that was found.
if isempty(Obj)
    Obj = visa('NI', IPaddress ); % NI VISA is used. if TekVISA is used, should be like Obj = visa('TEK', IPaddress )
else
    fclose(Obj);
    Obj = Obj(1);
end

Obj.InputBufferSize = InBuffersize;
Obj.OutputBufferSize = OutBuffersize;
Obj.Timeout = Timeout;
% Connect to instrument object, obj1.
fopen(Obj);

%% Creating a waveform
if AWG.Ch1.Enable
    binblock1 = BinBlock(AWG.Ch1, AWG.DAC_nbit);
    bytes = num2str(length(binblock1));
    header = ['#' num2str(length(bytes)) bytes];
    fwrite(Obj,[':WLIST:WAVEFORM:NEW "' AWG.Ch1.WFMName '",' ...
        num2str(length(AWG.Ch1.Data)) ', INTEGER;']);
    fwrite(Obj,[':WLIST:WAVEFORM:DATA "' AWG.Ch1.WFMName '",0,' ...
        num2str(length(AWG.Ch1.Data)) ',' header binblock1 ';']);
    fprintf(Obj,['SOURCE1:WAVEFORM "' AWG.Ch1.WFMName '"']);
end

if AWG.Ch2.Enable
    binblock2 = BinBlock(AWG.Ch2, AWG.DAC_nbit);
    bytes = num2str(length(binblock2));
    header = ['#' num2str(length(bytes)) bytes];
    fwrite(Obj,[':WLIST:WAVEFORM:NEW "' AWG.Ch2.WFMName '",' ...
        num2str(length(AWG.Ch2.Data)) ', INTEGER;']);
    fwrite(Obj,[':WLIST:WAVEFORM:DATA "' AWG.Ch2.WFMName '",0,' ...
        num2str(length(AWG.Ch2.Data)) ',' header binblock2 ';']);
    fprintf(Obj,['SOURCE2:WAVEFORM "' AWG.Ch2.WFMName '"']);
end
%% Instrument control and data generation
if AWG.ResetState
    
% fprintf(Obj,'*RST');
fprintf(Obj,['SOURCE1:SKEW ' num2str(AWG.Skew) 'PS ']);
fprintf(Obj,['AWGCONTROL:INTERLEAVE:STATE ' num2str(AWG.Interleave)]);
fprintf(Obj,['AWGCONTROL:INTERLEAVE:ZEROING ' num2str(AWG.Zeroing)]);% enable Zeroing

% fprintf(Obj,'AWGCONTROL:DC4:STATE 1');
% fprintf(Obj,'AWGCONTROL:DC4:VOLTAGE:OFFSET 1.73V');

if AWG.Ch1.Enable
    fprintf(Obj,['SOURCE1:FREQUENCY ' num2str(AWG.SampleRate)]);
    fprintf(Obj,['SOURCE1:DAC:RESOLUTION ' num2str(AWG.DAC_nbit)]);
end
if AWG.Ch2.Enable
    fprintf(Obj,['SOURCE2:FREQUENCY ' num2str(AWG.SampleRate)]);
    fprintf(Obj,['SOURCE2:DAC:RESOLUTION ' num2str(AWG.DAC_nbit)]);
end

fprintf(Obj,['SOURCE1:VOLTAGE:AMPLITUDE ' num2str(AWG.Amplitude)]);
fprintf(Obj,['SOURCE2:VOLTAGE:AMPLITUDE ' num2str(AWG.Amplitude)]);

if AWG.Ch1.Enable fprintf(Obj,'OUTPUT1:STATE ON'); end
if AWG.Ch2.Enable fprintf(Obj,'OUTPUT2:STATE ON'); end
% run AWG.
fprintf(Obj,'AWGCONTROL:RUN');
end

fclose(Obj);
flushinput(Obj);
flushoutput(Obj);
delete(Obj);

function y = BinBlock(Obj, DAC_nbit)
Data = uint16(2^DAC_nbit .* (Obj.Data + 0.5)-1);
Mk1 = uint16(Obj.Mk1);
Mk2 = uint16(Obj.Mk2);

if DAC_nbit ==8
    % 8-bit resoultion, MSB15-14 is for markers.
    Mk1Shift = bitshift(Mk1,14);
    Mk2Shift = bitshift(Mk2,15);
    DataShift = bitshift(Data,6);
    bs = bitor(Mk1Shift,Mk2Shift);
    bs2 = bitor(bs,DataShift);
    binblock = typecast(bs2,'uint8');
else
    % 10-bit resoultion
    DataShift = bitshift(Data,4);
    binblock = typecast(DataShift,'uint8');
end
y = binblock;

% 8 bits DAC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% integer uses 2 bytes, 16bits. For 8-bit resolution, DATA structure is shown below.
%   15      14    	13	12	11	10	9	8	7	6	5	4   3   2   1   0
%   Marker2 Marker1 B7 	B6 	B5 	B4 	B3 	B2	B1 	B0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% integer uses 2 bytes, 16bits. For 10-bit resolution, DATA structure is shown below.
%	15	14	13	12	11	10	9	8	7	6	5	4	3	2	1	0
%   0   0   B9	B8	B7	B6	B5	B4 	B3	B2 	B1 	B0  0   0   0   0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

