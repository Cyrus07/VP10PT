classdef MLSequenceDetection < DspAlg.SuperClassHandle
    % Viterbi Algorithm. Digital Communications 5th Edition, pp432
    % copyright2014 lingchen
    % version v 2.2

    properties
        ModulationFormat    = 'PAM';
        DecDelay        	= 20;
        ISI
        mn
    end
    properties (Dependent)
        L
    end
    properties (SetAccess = private)
        stateWeightMat
        stateWeightMat0
        DM
        h
        accuDist
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function obj = MLSequenceDetection(varargin)
            SetVariousProp(obj, varargin{:})
        end
        
        function l = get.L(obj)
            l = length(obj.ISI)-1;
        end
        
        function reset(obj)
            obj.RunCount = obj.RunCount+1;
            if obj.RunCount == 1

                switch obj.ModulationFormat
                    case 'PAM'
                        obj.h = modem.pammod;
                end
                obj.h.M = obj.mn;
                
                % calculate state weight
                intSet = (0:obj.mn^(obj.L+1)-1).';
                for l = 1:obj.L+1
                    csSet(:,obj.L+2-l) = mod(intSet, obj.mn);
                    intSet = floor(intSet/obj.mn);
                end
                % csSet is in order of i(k),i(k-1),...,i(k-L+1), i(k) belongs to {cs} and in
                % least-significant-difference order
                csSet = obj.h.modulate(csSet);
                % stateWeightMat is the pre-calculated weight for mn^(L+1) states,
                % {i(k), i(k-1),...,i(k-L)}. It is categorised in mn^L groups (rows), with
                % each group (row) of mn states weights, for different i(k-L) and fixed
                % {i(k),i(k-1),...,i(k-L+1)}. e.g. check reshape(csVec,mn,mn^L).'
                % stateWeightMat in in order of i(k),i(k-1),...,i(k-L+1)
                obj.stateWeightMat = reshape(csSet*obj.ISI,ones(1,obj.L+1)*obj.mn);
                obj.stateWeightMat = permute(obj.stateWeightMat, obj.L+1:-1:1);
                % the survival sequence
                % initial stateWeightMat for received sample v(L), state includes {i(L),
                % i(L-1), ... i(0)}, i(0) = 0. Thus, each row is a constant vector.
                obj.stateWeightMat0 = reshape(csSet*[obj.ISI(1:end-1);0],ones(1,obj.L+1)*obj.mn);
                obj.stateWeightMat0 = permute(obj.stateWeightMat0, obj.L+1:-1:1);
                obj.stateWeightMat0 = mean(obj.stateWeightMat0,obj.L+1);
                if obj.DecDelay < obj.L*10
                    obj.DecDelay = obj.L*10;
                end
            end
        end
        
        function estVec = Output(obj,x)
            if obj.Active
                reset(obj);
                % DM{L} = min(w.r.t.I(0)) Sigma{ ln(p(v(L)|I(L),I(L-1),...,I(0)) }.
                % Note that I(0) = 0, thus, DM{L} = Sigma{ ln(p(v(L)|I(L),I(L-1),...,I(1)) }
                obj.DM = (x(obj.L)-obj.stateWeightMat0).^2;
                % initial conditoin
                SrvvSeqMat = zeros(obj.DecDelay,obj.mn^obj.L);
                estVec = [];
                xPointer = obj.L+1;
                % iteration
                while xPointer<=length(x)
                    %% Viterbi
                    % iterate current distant metric,
                    % DM{L+k} = min(w.r.t.i(k)) [{DM{L+k-1} + ln(p(v(L+k)|i(L+k),...,i(k))]
                    % DM{L+k-1} is in the order of i(L+k-1), i(L+k-2), ..., i(k)
                    % ln(p(v(L+k)|i(L+k),...,i(k)) is in order of i(L+k), i(L+k-1), ..., i(k)
                    % DM{L+k-1} is expanded to :, i(L+k-1), i(L+k-2), ..., i(k)
                    dm =  reshape(repmat(obj.DM(:).',obj.mn,1),ones(1,obj.L+1)*obj.mn) ...
                        + (x(xPointer)-obj.stateWeightMat).^2;
                    % For each row, the minimal distance is w.r.t. survival metric and i(k)
                    [obj.DM, ind] = min(dm,[],obj.L+1);
                    SrvvSeqMat = [SrvvSeqMat(:,ind(:)); obj.h.Constellation(ind(:))];
                    [obj.accuDist(xPointer), ind] = min(obj.DM(:));
                    estVec = [estVec; SrvvSeqMat(1,ind)];
                    SrvvSeqMat(1,:) = [];
                    xPointer = xPointer +1;
                end
                [obj.accuDist(xPointer), ind] = min(obj.DM(:));
                estVec = [estVec; SrvvSeqMat(:,ind)];
                
                estVec = estVec(obj.DecDelay+1:end);
            else
                estVec = x;
            end
        end
        
    end
end