classdef WDspMain < WDspCondition
    %DSPALGORITHM Summary of this class goes here
    %   Three types of Boundary Condition are applied in this algorithm:
    %       Oneshot, Circular and Overlap.
    %   Circular and Overlap have similar structure with a small size of
    %       overlap processing data on a block-by-block basis.
    %   Oneshot does not have any boundary condition. The data is only
    %       generated and processed once.
    %   Copyright: ?2011 (dawei.zju@gmail.com)
    
    %   Last modified 2012-7-2
    
    properties
        OTG = 0; DCF = 0; TPE = 0;
        CMA = 0; FOC = 0; CPE = 0; BER = 0;
        %%%%%%%%%%%%%%%%%%%%%
        IsFirstRun = false
        BoundaryConditionType = 'oneshot'
        %%%%%%%%%%%%%%%%%%%%%
        AdcSampingRate = 50E9
        %%%%%%%%%%%%%%%%%%%%%
        OTG_methID = 0
        %%%%%%%%%%%%%%%%%%%%%
        DCF_Ntaps = 512
        DCF_Method = 'ideal'
        DCF_OverlapRatio = 0.5
        DCF_Dispersion = 0.0
        %%%%%%%%%%%%%%%%%%%%%
        TPE_ErrGain = 0.001
        TPE_szBlock = 32
        TPE_leeBias = 1
        TPE_decFlag = 1
        TPE_Config = 'Feedback'
        TPE_estMeth = 'gardner'
        TPE_intMeth = 'linear'
        %%%%%%%%%%%%%%%%%%%%%
        CMA_PolarMux = 1
        CMA_errFunc_1 = 1
        CMA_errFunc_2 = 1
        CMA_errFunc_3 = 3
        CMA_gain_1 = 1E-3
        CMA_gain_2 = 1E-3
        CMA_gain_3 = 1E-6
        CMA_ntaps_1 = 5
        CMA_ntaps_2 = 5
        CMA_ntaps_3 = 5
        CMA_Iteration_1 = 0
        CMA_Iteration_2 = 6
        CMA_Iteration_3 = 0
        %%%%%%%%%%%%%%%%%%%%%
        CPE_Method = 'block'
        CPE_ErrorGain = 0.01
        CPE_BlockSize = 32
        CPE_appML = 1
        CPE_MLiter = 1
        %%%%%%%%%%%%%%%%%%%%%
        BER_Differential = 0
        BitReference = []
        SymReference = []
    end
    properties (SetAccess = private)
        Boundary
        OTG_estPhi
        TPE_estPhi
        TPE_epsilon
        CMA_H1
        CMA_H2
        CMA_MSE
        CMA_Deth
        CPE_IniPhi
        CPE_EstPhi
        Plot_H1
        Plot_H2
        OTG_outdata
        TPE_outdata
        CPE_outdata
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% main functions
    methods
        function this = DspMain(varargin)
            SetVariousProp(this, varargin{:})
        end        
        %% MAIN PROCESSING ENTRY
        function argout = process(this, rx_signal)
            
            reset(this)
            
            rx = [rx_signal{1}.Amplitude; rx_signal{2}.Amplitude];
            rx = rx.';
            LoadBoundary(this)
            % enviroment variable
            sps = this.DSP_SamplePerSymbol;
            mn = this.DSP_ConstellationOrder;
            %% orthogonalization
            if this.OTG
                [OTG_OUT, phi] = DspAlg.Orthogonal(rx,this.OTG_methID);
                this.OTG_estPhi = phi / pi * 180;
            else
                OTG_OUT = rx;
                this.OTG_estPhi = 0;
            end
            this.OTG_outdata = OTG_OUT;
            %% dispersion compensation
            if this.DCF
                N = this.DCF_Ntaps;
                D = this.DCF_Dispersion;
                R = this.DCF_OverlapRatio;
                Fs = this.DSP_SymbolRate * this.DSP_SamplePerSymbol;
                Lambda = 299792458 / this.DSP_CenterFrequency;
                Method = this.DCF_Method;
                DCF_OUT = DspAlg.FrequencyDCF( OTG_OUT, D, Lambda, ...
                    Fs, N, Method, R );
            else
                DCF_OUT = OTG_OUT;
            end
            %% timing recovery
            if this.TPE
                [TPE_OUT phi tau] = DspAlg.FeedforwardTPE( DCF_OUT, ...
                    mn, sps, ...
                    this.TPE_szBlock,this.TPE_leeBias, ...
                    this.TPE_estMeth,this.TPE_intMeth,this.TPE_decFlag );
                this.TPE_estPhi = phi;
                this.TPE_epsilon = tau;
                sps = 1;
            else
                TPE_OUT = DCF_OUT;
            end
            this.TPE_outdata = TPE_OUT;
            %% cut off anyway
            cutoff = this.Boundary.OverlapLength / 2;
            %% polarization demultiplex
            if this.CMA
                
                halftaps = floor(this.CMA_ntaps_2/2);
                
                if strcmpi(this.BoundaryConditionType,'Oneshot')
                    % extend signal periodically
                    signal = [...
                        TPE_OUT(end-halftaps + 1 : end, :); ...
                        TPE_OUT; ...
                        TPE_OUT(1 : halftaps, :)...
                        ];
                else
                    % cut off
                    signal = ...
                        TPE_OUT( cutoff*sps-halftaps+1 : end-cutoff*sps+halftaps, :);
                    % run once
                    this.CMA_Iteration_2 = 1;
                end
                % demultiplexing
                [CMA_OUT,this.CMA_MSE,this.CMA_Deth,this.CMA_H1,this.CMA_H2] = ...
                    DspAlg.PolarizationDemux( signal, mn, sps, ...
                    this.CMA_PolarMux, this.CMA_gain_1,this.CMA_gain_2,this.CMA_gain_3, ...
                    this.CMA_ntaps_1,this.CMA_ntaps_2,this.CMA_ntaps_3, ...
                    this.CMA_errFunc_1,this.CMA_errFunc_2,this.CMA_errFunc_3, ...
                    this.CMA_Iteration_1,this.CMA_Iteration_2,this.CMA_Iteration_3);
            else
                CMA_OUT = TPE_OUT( cutoff*sps+1 : end-cutoff*sps, : );
            end
            %% carrier phase recovery
            if this.CPE
                [CPE_OUT phase_noise] = DspAlg.FeedforwardCPE( ...
                    CMA_OUT, mn, ...
                    this.CPE_BlockSize,this.CPE_Method, ...
                    this.CPE_appML,this.CPE_MLiter );
                this.CPE_EstPhi = phase_noise;
                this.CPE_IniPhi = phase_noise(end,:);
            else
                CPE_OUT = CMA_OUT;
            end
            this.CPE_outdata = CPE_OUT;
            %% calculate the BER
            if this.BER
                ben = DspAlg.BerTesting( CPE_OUT, mn, ...
                    this.BER_Differential, this.BitReference );
            else
                ben = 0;
            end
            
            SaveBoundary(this)
            
            argout = ben;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% sub functions
    methods
        function conclud(this)
            str = ['dsp: DCF:' num2str(this.DCF) ...
                ' TPE:' num2str(this.TPE) ...
                ' CMA:' num2str(this.CMA) ...
                ' CPE:' num2str(this.CPE) ...
                ' FOC:' num2str(this.FOC) ...
                ' BER:' num2str(this.BER) ...
                ' bc-type:' this.BoundaryConditionType ...
                '..eol'];
            disp(str)
        end
        function plot_results(this)
            if strcmpi(this.BoundaryConditionType,'oneshot')
                this.Plot_H1 = w_figure('Visible','off');
            end
            mn = this.DSP_ConstellationOrder;
            sig_cma = DspAlg.Normalize( this.TPE_outdata, mn );
            sig_cpe = DspAlg.Normalize( this.CPE_outdata, mn );
            
            figure( this.Plot_H1 )
            % constrllations
            subplot(4,4,[1 5])
            plot( sig_cma(:,1), 'b.' );
            ylabel TPE.Output; title Pol.X; 
            axis equal; grid on
            subplot(4,4,[2 6])
            plot( sig_cma(:,2), 'r.' );
            title Pol.Y ; 
            axis equal; grid on
            subplot(4,4,[9 13])
            plot( sig_cpe(:,1), 'b.' );
            ylabel CPE.Output; 
            axis equal; grid on
            subplot(4,4,[10 14])
            plot( sig_cpe(:,2), 'r.' );
            axis equal; grid on
            % parameters
            subplot(4,4,[3 4])
            plot( this.TPE_estPhi )
            title TPE.phase; grid on;  ylim([0 2])
            subplot(4,4,[7 8])
            plot( this.CMA_Deth(:) )
            title CMA.deth;  grid on
            subplot(4,4,[11 12])
            plot( 10*log10(this.CMA_MSE),'r.-' )
            title CMA.mse;   grid on;
            subplot(4,4,[15 16])
            plot( this.CPE_EstPhi,'g' )
            title CPE.phase; grid on
            
            drawnow
        end
        
        function LoadBoundary(this)
            this.CMA_H1 = this.Boundary.CmaTaps.H1;
            this.CMA_H2 = this.Boundary.CmaTaps.H2;
            this.CPE_IniPhi = this.Boundary.CpePhase;
            this.Plot_H1 = this.Boundary.Plot_H1;
            this.Plot_H2 = this.Boundary.Plot_H2;
        end
        function SaveBoundary(this)
            this.Boundary.CmaTaps.H1 = this.CMA_H1;
            this.Boundary.CmaTaps.H2 = this.CMA_H2;
            this.Boundary.CpePhase = this.CPE_IniPhi;
            this.Boundary.Plot_H1 = this.Plot_H1;
            this.Boundary.Plot_H2 = this.Plot_H2;
        end
        
        function reset(this)
            if ~strcmpi(this.DCF_Method,'ideal') && ...
                    ~strcmpi(this.DCF_Method,'overlap')
                error('DSPMAIN::incurrect dcf method')
            end
            if ~strcmpi(this.CPE_Method,'pll') && ...
                    ~strcmpi(this.CPE_Method,'block') && ...
                    ~strcmpi(this.CPE_Method,'slide')
                error('DSPMAIN::incurrect cpe method')
            end
%             if ~strcmpi(this.CMA_Version,'fast') && ...
%                     ~strcmpi(this.CMA_Version,'slow') && ...
%                     ~strcmpi(this.CMA_Version,'lms')
%                 error('DSPMAIN::incurrect cma method')
%             end
            switch this.BoundaryConditionType
                case 'oneshot'
                    this.IsFirstRun = true;
                    this.Boundary = BoundaryCondition;
                    this.Boundary.OverlapLength = 0;
                case {'overlap','circular'}
                    if this.IsFirstRun
                        this.Boundary = BoundaryCondition;
                        this.Boundary.Plot_H1 = w_figure('Visible','off');
                        % this.Boundary.Plot_H2 = figure();
                    end
                otherwise
                    error('DSPMAIN::incurrect boundary condition type')
            end
        end
        
    end
    
end