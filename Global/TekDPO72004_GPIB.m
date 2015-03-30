% TekDPO72004 GPIB control programing
%
% Example:
%	[v1,v2,v3,v4,v5,v6] = callDvc(dvcHandle,cmdStr)
%			dvcHandle	- structure including control handles of devices

% Version
%	2010-08-12	C. Li, start

function [varargout] = TekDPO72004_GPIB(h,cmdStr,parmCell)

switch cmdStr
	case 'start'
		set(h,'EOSMode','read&write');
		set(h,'InputBufferSize',5000000);
		set(h,'OutputBufferSize',5000000);
		fopen(h);
		fprintf(h,'*IDN?');
		varargout{1} = h;
		varargout{2} = fscanf(h);
        
    case 'stop'
        fclose(h);
		
	case 'readWaveform'
		callDev(h,'WFMOutpre:ENCdg ascii');		% set output tp ASCII	
		callDev(h,'acquire:state 1');
        pause(1);
		callDev(h,'acquire:state 0');	
		yscale	= str2num(callDev(h,'wfmoutpre:ymult?'));
		callDev(h,['data:stop ' num2str(parmCell{1})]);	
        nch = length(parmCell) - 1;
        for ii = 1:nch
            callDev(h,['data:source ' parmCell{ii+1}]);
            varargout{ii} = str2num(callDev(h,'curve?')) * yscale;
        end
        clrdevice(h)
        flushinput(h)
        
    case 'setdeskew'
		callDev(h,['CH',num2str(parmCell{1}),':DESKEW ',num2str(parmCell{2})]); pause(0.1);
        
	case 'debug'
		disp('TekDPO72004_GPIB debug'); keyboard;
		
	otherwise
		display('Un-supported command in TekDPO72004_GPIB.m');
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sub-functions
function A = callDev(h,cmdStr)
fprintf(h,cmdStr);
% pause(1)
if cmdStr(end) == '?'
	A = fscanf(h);
else
	A = '';
end
return