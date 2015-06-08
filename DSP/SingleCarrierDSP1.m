classdef SingleCarrierDSP1 < DSP_
    %SingleCarrierDSP1   v1.0, Lingchen Huang, 2015/6/8
    
    properties
        % sps
        % mn
        % Rs
        
        se_method = 'ideal';
        se_cd   = 0;
        se_fc   = 193.1e12;
        se_bs   = 512;
        
        ts_bs   = 512;
        ts_estmethod = 'lee'
        ts_interpmethod = 'linear'
        ts_downsampling = 1
        
%         fs1_
        
        ae_mu       = [1e-4 1e-5 1e-6]
        ae_ntaps 	= [13 13 13]
        ae_errid 	= [1 1 3]
        ae_iter     = [0 30 0]
        ae_downsamping = 0
        
%         fs2_

        ps_bs       = 21
        ps_method   = 'bps'
        ps_ml       = 0
    end
    properties
        Scope
    end
    methods
        %%
        function obj = SingleCarrierDSP1(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Init(obj)
            obj.Scope = SignalAnalyzer;
        end
        %%
        function y = Processing(obj, x)
            sps = obj.sps;
            DSPIN = DspAlg.Normalize(cell2mat(x), obj.mn);
            %% static eq.: CDC
            [DCFOUT,H] = DspAlg.FrequencyDCF(DSPIN,obj.se_cd,obj.se_fc,obj.Rs*sps,obj.se_bs,obj.se_method);
            %% timing sync

            % [TPEOUT,tpn] = DspAlg.FeedbackTPE(DCFOUT,mn,sps,4,1e-4,'gardner','linear');
            % [TPEOUT,tpn] = DspAlg.FeedbackTPE(DCFOUT,mn,sps,64,1e-2,'godard','linear');
            % [TPEOUT,tpn] = DspAlg.FeedbackTPE(DCFOUT,mn,sps,1e-4,'gardner','linear');
            % [TPEOUT,tpn] = DspAlg.FeedbackTPE(DCFOUT,mn,sps,1e-4,'gardner','parabolic');
            [TPEOUT,tpn] = DspAlg.FeedforwardTPE(DCFOUT,obj.mn,sps,...
                obj.ts_bs,1,obj.ts_estmethod,obj.ts_interpmethod,obj.ts_downsampling);
%             TPEOUT = DCFOUT;
            sps = 1;
            %% frequency sync 1
            %% adaptive eq.: CMA
            [CMAOUT,mse] = DspAlg.PolarizationDemux(TPEOUT,obj.mn,sps,1,...
                obj.ae_mu,obj.ae_ntaps,obj.ae_errid,obj.ae_iter,obj.ae_downsamping);
            
            %% frequency sync 2
            [FOCOUT,df] = DspAlg.FeedforwardFOC(CMAOUT,obj.Rs, 0);
            %% phase sync
            % [CPEOUT,pn] = DspAlg.FeedforwardCPE(FOCOUT,mn,bs,'block',appML,iterML);
            % [CPEOUT,pn] = DspAlg.FeedforwardCPE(FOCOUT,mn,bs,'slide',appML,iterML);
%             [CPEOUT,pn] = DspAlg.FeedforwardCPE(FOCOUT,obj.mn,obj.ps_bs,obj.ps_method,obj.ps_ml);
            % [CPEOUT,pn] = DspAlg.FeedbackCPE(FOCOUT,mn,mu,[0,0],appML,bs,iterML);
            % [CPEOUT,pn] = cpe_pll_2nd(FOCOUT,mn,0.012,0.012,appML,bs,iterML);
            CPEOUT = FOCOUT;
            %%
            y = mat2cell(CPEOUT, size(CPEOUT,1), ones(1,size(CPEOUT,2)));
        end
        %%
        function Reset(obj)
            
        end
    end
end