classdef DecisionHard < Subsystem_
    %DecisionHard v1.0, Lingchen Huang, 2015/4/1
    
    properties
        nPol
        BER
        TCErrorCount    = 200
        TCBitCount      = 2^16
        % Dec
        hMod
        DispEVM
        % FEC
        FECType
        % BERT
        RefMsg
        DispIdx
        DispBER
    end
    properties (SetAccess = private)
        Dec
        FEC
        BERTest
    end
    
    methods
        %%
        function obj = DecisionHard(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Processing(obj, x)
            %
            % receiving and make hard decision
            dec = obj.Dec.Processing(x);
            
            % FEC
            fec = obj.FEC.Processing(dec);
            
            % calculate bit error rate
            obj.BERTest.RefBits = obj.RefMsg;
            obj.BERTest.Processing(fec);
            
            % Termination condition
            if sum(obj.BERTest.ErrCount) >= obj.TCErrorCount...
                    && sum(obj.BERTest.BitCount) >= obj.TCBitCount
                obj.BER = sum(obj.BERTest.ErrCount(3:end))...
                    / sum(obj.BERTest.BitCount(3:end));
            end
        end
        %%
        function Init(obj)
            obj.Dec         = Decision_('nPol', obj.nPol,...
                    'hMod', obj.hMod,...
                    'DispEVM', obj.DispEVM);
            Init(obj.Dec);
            obj.FEC         = FECDecoders('nPol', obj.nPol,...
                    'FECType', obj.FECType);
            Init(obj.FEC);
            obj.BERTest     = BERTAsync('nPol', obj.nPol,...
                    'DispIdx', obj.DispIdx,...
                    'DispBER', obj.DispBER);
            Init(obj.BERTest);
            obj.BER = [];
        end
        %%
        function Reset(obj)
            obj.RefMsg  = [];
            obj.BER     = [];
            Reset(obj.Dec);
            Reset(obj.FEC);
            Reset(obj.BERTest);
        end
    end
end
