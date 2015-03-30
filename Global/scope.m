function data = scope(Scope)
%% Interface configuration and instrument connection
% Scope IP address such as 'TCPIP::10.71.103.173::INSTR'
% Find a VISA-TCPIP object.
IPaddress = strcat('TCPIP0::', Scope.IPaddress, '::inst0::INSTR');      % Scope IP address such as 'TCPIP::10.71.103.173::INSTR'
InBuffersize = Scope.InBuffersize;
OutBuffersize = Scope.OutBuffersize;
SampleRate = Scope.SampleRate;
Timeout = Scope.Timeout;
Channel = Scope.ChannelNo;
Points = Scope.Points;
VerticalScale = Scope.Vertical;

Obj = instrfind('Type', 'visa-tcpip', 'RsrcName', IPaddress, 'Tag', '');

% Create the VISA-TCPIP object if it does not exist
% otherwise use the object that was found.
if isempty(Obj)
    Obj = visa('NI', IPaddress);
else
    fclose(Obj);
    Obj = Obj(1);
end
% Set the buffer size
Obj.InputBufferSize = Scope.InBuffersize;
Obj.OutputBufferSize = Scope.OutBuffersize;
% Set the timeout value
Obj.Timeout = Scope.Timeout;
% Set the Byte order
Obj.ByteOrder = 'littleEndian';
fopen(Obj);
flushinput(Obj);
flushoutput(Obj);

%% %%% Scope SETUP
DSA.ResetState=1;

if DSA.ResetState
% fprintf(Obj,'*RST'); % Reset the instrument
% fprintf(Obj,'AUTOSet EXECute'); % Autoscale

% Horizontal Settings
% MANUAL mode can change the sample rate and the record length.
fprintf(Obj,'HORizontal:MODE MANUAL'); 
fprintf(Obj,['HORIZONTAL:MODE:SAMPLERATE ' num2str(Scope.SampleRate)]);
fprintf(Obj,['HORIZONTAL:MODE:RECORDLENGTH ' num2str(Scope.Points)]);

%Vertical Settings
ChannelNum = length(Channel); 

for index = 1:ChannelNum
fprintf(Obj,['SELect:CH' num2str(Channel(index)) ' ON']); % Specify Displayed Channel
end
if Scope.BandWidth < 20e9
    fprintf(Obj,['CH1:BANDWIDTH ' num2str(Scope.BandWidth)]);
    fprintf(Obj,['CH3:BANDWIDTH ' num2str(Scope.BandWidth)]);
    fprintf(Obj,'CH1:BANDWIDTH:ENHANCED AUTO');
    fprintf(Obj,'CH3:BANDWIDTH:ENHANCED AUTO');
    fprintf(Obj,'CH1:BANDWIDTH:ENHANCED:FORCE ON');
    fprintf(Obj,'CH3:BANDWIDTH:ENHANCED:FORCE ON');
end
end

%% % %%% OUTPUT FORMAT
data = zeros(length(Channel),Points); % output data from Scope

for index = 1:length(Channel)
fprintf(Obj,['SELect:CH' num2str(Channel(index)) ' ON']); % Specify Displayed Channel
end
fprintf(Obj,'ACQuire:MODe SAMple');% Set up acquisition type. 
fprintf(Obj,'ACQuire:SAMPlingmode RT');% Real Time
fprintf(Obj,'ACQuire:STATE ON'); % Run
fprintf(Obj,'ACQuire:STOPAfter RUNSTop');
% fprintf(Obj,'ACQuire:STOPAfter SEQuence');
pause(3);
fprintf(Obj,'ACQuire:STATE OFF'); % STOP

Y_Multiple = str2double(query(Obj,'WFMOUTPRE:YMULT?')); %#ok<*ST2NM>
Y_Offset = str2double(query(Obj,'WFMOUTPRE:YOFF?'));
Y_Zero = str2double(query(Obj,'WFMOUTPRE:YZERO?'));

for index = 1:ChannelNum
    fprintf(Obj,['DATa:SOUrce CH' num2str(Channel(index))]);
    fprintf(Obj,':DATa:ENCdg RIBinary');% ASCIi|FAStest|RIBinary|RPBinary|FPBinary|SRIbinary|SRPbinary|SFPbinary
    fprintf(Obj,'WFMOutpre:BYT_Nr 1');% 1 or 2
    fprintf(Obj,[':DATA:START ' num2str(1) ';STOP ' num2str(Points)]);
    fprintf(Obj,'CURVE?');
    data1 = binblockread(Obj,'int8');
    data(index,:) = reshape(data1,1,[]);
end
X_Zero = str2num(query(Obj,'WFMOUTPRE:XZERO?'));% get x zero
Sampling_Interval = str2num(query(Obj,'WFMOUTPRE:XINCR?'));% get the sampling interval 
Trigger_Point = str2num(query(Obj,'WFMOUTPRE:PT_OFF?'));% get the trigger point within the record
m = query(Obj,'WFMOUTPRE:YMULT?');
Y_Multiple = str2num(m);
m = query(Obj,'WFMOUTPRE:YOFF?');
Y_Offset = str2num(m);
m = query(Obj,'WFMOUTPRE:YZERO?');
Y_Zero = str2num(m);
data = Y_Multiple*(data - Y_Offset) - Y_Zero;% fprintf(Obj,'HEADer On');% Enable header for query
% query(Obj,'WFMOutpre?')% Query the output setting
% fprintf(Obj,'HEADer Off');% disable header for query
fclose(Obj);
flushinput(Obj);
flushoutput(Obj);
delete(Obj);