classdef SourceBinary < ActiveModule
    %SourceBinary v1.0, Lingchen Huang, 2015/3/16
    %
    %
    %   Block struction is as following:
    %   Bit_Gen -> Buffer1 -> FEC_Encoder -> Buffer2 -> Output
    %   Bit_Gen calls GetBitseq method to generate bit sequence, defined in
    %   SourceBinary
    %   Buffer1 is defined as FECBuffer, implementing rate conversion to
    %   adapt FEC_Encoder
    %   FEC_Encoder pops msg from Buffer1, and encoder it, then push into
    %   Buffer2.
    %   Buffer2 is defined as BitsBuffer in SourceBinary, implementing rate
    %   conversion to meet output bit sequence length requirement.
    %
    %   Note that, 
    %   MsgBuffer is defined as msg bits buffer for BER
    %   calculation at receiver end;
    %   BitseqLen has two value if overlap simulation is the case, then
    %   BitseqLen(1) correspons to first run and BitseqLen(2) to later runs
    %
    %   Also see, SourceBinary
    %
    %
    %%
    properties
        BitsType   	= 'Random'; % PRBS, Random, UserDef
        BitseqLen   = 2^12
        PRBSOrder   = 7
        UserDefined = []
        FECType     = 'None'
    end
    properties (SetAccess = protected)
        Output      = []
        MsgBuffer
    end
    properties (Access = private)
        Count       = 0
        FECBuffer
        BitsBuffer
        bitseqlen
        FECMsgLen
        PRBSDeCorLen
    end
    
    methods
        %%
        function obj = SourceBinary(varargin)
            SetVariousProp(obj, varargin{:})
            obj.PRBSDeCorLen = randi([0,2^obj.PRBSOrder-1]);
        end
        %%
        function Reset(obj)
            obj.Count = 0;
            Init(obj);
        end
        %%
        function Init(obj)
            % if system overlap is zero, BitseqLen is a scaler,
            % or it has two value, the first of which is for the first run,
            % and the other one is for the later runs.
            obj.BitsBuffer = BUFFER;
            obj.FECBuffer = BUFFER;
            obj.MsgBuffer = BUFFER;
            switch lower(obj.FECType)
                case 'rs'
                    obj.FECMsgLen = 239*8;
                case 'ldpc'
                    obj.FECMsgLen = [];
                case 'rs-ldpc'
                    obj.FECMsgLen = [];
                case 'none'
                    obj.FECMsgLen = obj.BitseqLen(end);
            end
        end
        %%
        function y = Processing(obj)
            obj.Count = obj.Count + 1;
            if obj.Count == 1
                obj.bitseqlen = obj.BitseqLen(1);
            else
                obj.bitseqlen = obj.BitseqLen(end);
            end
            % "=" to ensure BitsBuffer never to be empty
            while length(obj.BitsBuffer.Buffer) <= obj.bitseqlen
                while length(obj.FECBuffer.Buffer) < obj.FECMsgLen
                    obj.FECBuffer.Input(GetBitseq(obj));
                end
                MsgWord = obj.FECBuffer.Output(obj.FECMsgLen);
                CodeWord = obj.FECEnc(MsgWord);
                obj.BitsBuffer.Input(CodeWord);
                obj.MsgBuffer.Input(MsgWord);
            end
            y = obj.BitsBuffer.Output(obj.bitseqlen);
        end
        %%
        function Bits = GetBitseq(obj)
            switch lower(obj.BitsType)
                case 'random'
                    % generating persistent random bit sequence,
                    Bits = randi([0,1], 2^12, 1);
                case 'prbs'
                    % set random number generator seed, seed number is
                    % pre-defined and not changable.
                    rngCurrState = SetRandomSeed(9425);
                    Bits = randi([0,1], 2^obj.PRBSOrder-1, 1);
                    % recover previous random number generator seed
                    SetrngState(rngCurrState);
                    % de-correlate output sequence for each instance
                    Bits = circshift(Bits, obj.PRBSDeCorLen);
                case 'userdef'
                    Bits = reshape(obj.UserDefined, [], 1);
                otherwise
            end
        end
        %%
        function y = FECEnc(obj, x)
            % FEC coder, RS code and LDPC code are supported.
            % Interleaving has not yet been tested.
            switch lower(obj.FECType)
                case 'rs'
                    msgword = bi2de(reshape(x,8,[]).');
                    codeword = FEC.rs_enc(msgword, 255, 239);
                    y = de2bi(codeword.').';
                    y = y(:);
                case 'ldpc'
                    y = x;
                case 'rs-ldpc'
                    y = x;
                case 'none'
                    y = x;
            end
        end
    end
end

