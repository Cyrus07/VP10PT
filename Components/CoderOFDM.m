classdef CoderOFDM < Coder_
    % copyright2014 lingchen
    % last modified @ 2014 , lingchen
    %%
    properties
        OFDM                = struct('nFFT', 256,...
                                    'nGI', 1 / 8 * 256,...
                                    'nSubCarr', 192,...
                                    'nPilot', 10,...
                                    'IdxSubCarr', [],...
                                    'IdxPilot', []);
        PilotSequence
        PreEmphasisActive    = false
        PreEmphasisFile
    end
    methods
        %%
        function obj = CoderOFDM(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function init(obj)
            if rem(obj.OFDM.nSubCarr,2)~=0 error('Number of Subcarrier should be even');end
            if rem(obj.OFDM.nPilot,2)~=0 error('Number of Pilot should be even');end
            if isempty(obj.OFDM.IdxSubCarr) || isemtpy(obj.OFDM.IdxPilot)
                tmp1 = 1 + (1:(obj.OFDM.nSubCarr+obj.OFDM.nPilot)/2); % set
                tmp2 = 1 + round(linspace(obj.OFDM.nPilot/2,...
                    (obj.OFDM.nSubCarr+obj.OFDM.nPilot)/2,...
                    obj.OFDM.nPilot/2)); % set of Pilot
                tmp3 = setdiff(tmp1,tmp2); % set of SubCarr
                obj.OFDM.IdxSubCarr = [tmp3 fliplr(obj.OFDM.nFFT+2-tmp3)].';
                obj.OFDM.IdxPilot = [tmp2 fliplr(obj.OFDM.nFFT+2-tmp2)].';
            end
            if isempty(obj.PilotSequence)
                % obj.PilotSequence = PNSequence('QPSK', obj.NumPilot);
                obj.PilotSequence = ones(obj.OFDM.nPilot,1);
            end
            for pol = 1:obj.PolarDiversity
                obj.OverlapBuf{pol} = BUFFER('Length', ...
                    obj.FrameLen/ (obj.OFDM.nFFT+obj.OFDM.nGI) * obj.OFDM.nSubCarr);
            end
        end
        %%
        function Processing(obj)
            for n = 1:length(obj.Input)
                Check(obj.Input{n}, 'DigitalSignal');
            end
            if isempty(obj.Output)
                init(obj);
            end
            for pol = 1:obj.PolarDiversity
                % push in buffer
                obj.OverlapBuf{pol}.Input(obj.Input{pol}.E);
                obj.Output{pol} = Copy(obj.Input{pol});
                % read buffer
                syms = reshape(obj.OverlapBuf{pol}.Buffer, obj.OFDM.nSubCarr, []);
                rf = obj.DoCoding(syms);
                obj.Output{pol}.E = rf;
            end
        end
        %%
        function rf = DoCoding(obj, mat)
            pilot = repmat(obj.PilotSequence, 1, size(mat,2));
            mat = [mat;pilot];
            ind = [obj.OFDM.IdxSubCarr; obj.OFDM.IdxPilot];
            matfd = zeros(obj.OFDM.nFFT, size(mat,2));
            mat = obj.DoPreemphasis(mat, ind);
            matfd(ind,:) = mat;
            mattd = sqrt(obj.OFDM.nFFT)*ifft(matfd);
            pre = round(obj.OFDM.nGI/2);
            post = obj.OFDM.nGI - pre;
            mattdcp = [mattd(obj.OFDM.nFFT-pre+1:obj.OFDM.nFFT,:); ...
                mattd; ...
                mattd(1:post,:)];
            rf = reshape(mattdcp, [], 1);
        end
        %%
        function y = DoPreemphasis(obj, x, ind)
            if obj.PreEmphasisActive
                load(obj.PreEmphasisFile,'ce');
                y = diag(ce(ind)) * x;
            else
                y = x;
            end
        end
        %%
        function bits_number = DemandBitsNumPerPol(obj)
            if rem(obj.FrameLen,obj.OFDM.nFFT+obj.OFDM.nGI)~=0 
                error('INVALID FRAME LENGTH');
            end
            if rem(obj.FrameOverlapLen,obj.OFDM.nFFT+obj.OFDM.nGI)~=0 
                error('INVALID FRAME OVERLAP LENGTH');
            end
            bits_number(1) = obj.FrameLen ...
                / (obj.OFDM.nFFT+obj.OFDM.nGI) * obj.OFDM.nSubCarr * sum(log2(obj.mn));
            bits_number(2) = (obj.FrameLen - obj.FrameOverlapLen)...
                / (obj.OFDM.nFFT+obj.OFDM.nGI) * obj.OFDM.nSubCarr * sum(log2(obj.mn));
        end
    end
    
end

