function ExportToDAC(Ch1, Ch2)

% initial Channel 1, if exists
if nargin<1
    error('THERE IS NO INPUT TO DAC');
end
AWG.Ch1.Enable = 1;
if isempty(Ch1.Mk1)
    Ch1.Mk1 = zeros(size(Ch1.Data));
end
AWG.Ch1.Mk1 = reshape(Ch1.Mk1,1,[]);
if isempty(Ch1.Mk2)
    Ch1.Mk2 = zeros(size(Ch1.Data));
end
AWG.Ch1.Mk2 = reshape(Ch1.Mk2,1,[]);
if isempty(Ch1.WFMName)
    Ch1.WFMName = 'WFMCH1';
end
AWG.Ch1.WFMName = Ch1.WFMName;
Data(1,:) = reshape(Ch1.Data,1,[]);

% initial Channel 2, if exists
if nargin<2
    AWG.Ch2.Enable = 0;
    AWG.Ch2.Data = zeros(size(Data));
else
    AWG.Ch2.Enable = 1;
    if isempty(Ch2.Mk1)
        Ch2.Mk1 = zeros(size(Ch2.Data));
    end
    AWG.Ch2.Mk1 = reshape(Ch2.Mk1,1,[]);
    if isempty(Ch2.Mk2)
        Ch2.Mk2 = zeros(size(Ch2.Data));
    end
    AWG.Ch2.Mk2 = reshape(Ch2.Mk2,1,[]);
    if isempty(Ch2.WFMName)
        Ch2.WFMName = 'WFMCH2';
    end
    AWG.Ch2.WFMName = Ch2.WFMName;
    Data(2,:) = reshape(Ch2.Data,1,[]);
end

Data = Data/max(Data(:))/2;
Data = asin(Data*1.3);
Data = Data/max(Data(:))/2;
AWG.Ch1.Data = Data(1,:);
AWG.Ch2.Data = Data(2,:);

AWG.IPaddress = '192.168.74.92';       % AWG IP address such as 'TCPIP::10.71.103.173::INSTR'
AWG.InBuffersize = 20e6;    % Input Buffer Size, such as 4e6 (not sure the unit)
AWG.OutBuffersize = 20e6;   % OutPut Buffer Size, such as 4e6 
AWG.Timeout = 10;         % Time Out in Second, if no response within this duration , function returns

AWG.Interleave = 0;
AWG.Zeroing = 0;
AWG.SampleRate = Default.SamplingRate;      % AWG SampleRate, such as 10e9

AWG.ResetState = 0;
AWG.DAC_nbit = 8;        % OutPut DAC resolution, such as 8
AWG.Skew = 0;
AWG.Amplitude = 0.3;

awg(AWG);

