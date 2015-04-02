classdef DecisionHard < ActiveModule
    %DecisionHard v1.0, Lingchen Huang, 2015/4/1
    
    properties
        nPol
        Input
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
        function Processing(obj)
            %
            % receiving and make hard decision
            obj.Dec.Input = obj.Input;
            obj.Dec.Processing();
            
            % FEC
            obj.FEC.Input = obj.Dec.OutputBit;
            obj.FEC.Processing();
            
            % calculate bit error rate
            obj.BERTest.RefBits = obj.RefMsg;
            obj.BERTest.Input = obj.FEC.Output;
            obj.BERTest.Processing();
            
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
            obj.Input   = [];
            obj.RefMsg  = [];
            obj.BER     = [];
            Reset(obj.Dec);
            Reset(obj.FEC);
            Reset(obj.BERTest);
        end
    end
end
