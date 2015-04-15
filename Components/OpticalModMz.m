classdef OpticalModMz < Optical_
    %OpticalModMz Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ExRatio     = 99
        PushPull    = true
        VpiRf       = 3.0
        VpiDC       = 3.0
        Bias        = -1.5
        ModDepth    = 1.0
    end
    properties (Dependent)
        powSplitRatio
        ampSplitRatio
    end
    
    methods
        function obj = OpticalModMz( varargin )
            SetVariousProp(obj, varargin{:})          
        end
        
        function asr = get.ampSplitRatio(obj)
            if obj.ExRatio >= 99
                asr = [sqrt(2)/2,sqrt(2)/2];
            else
                Imperfect = sqrt(db2pow(-1*obj.ExRatio));
                Yupper = sqrt(0.5+Imperfect);
                Ylower = sqrt(0.5-Imperfect);
                asr = [Yupper,Ylower];
            end
        end
        
        function psr = get.powSplitRatio(obj)
            psr = obj.ampSplitRatio.^2;
        end
        
        %% main modulating functionality
        function y = Processing(obj, x, uE, dE)
            Check(x, 'OpticalSignal');
            Check(uE, 'ElectricalSignal');
            Check(dE, 'ElectricalSignal');
            y = Copy(x);
            
            if obj.Active
                y.Rs = uE.Rs;
                
                phi1 = pi*(obj.ModDepth*uE.E)/obj.VpiRf...
                    +pi*obj.Bias/obj.VpiDC;
                phi2 = pi*(obj.ModDepth*dE.E)/obj.VpiRf...
                    +pi*obj.Bias/obj.VpiDC;
                
                if obj.PushPull,  phi2 = -phi2;  end
                
                [xi, xq] = OpticalYCoupler.Processing(x);
                a1 = xi.Ex.*( ...
                    obj.ampSplitRatio(1) * exp(1j*phi1) + ...
                    obj.ampSplitRatio(2) * exp(1j*phi2) );
                a2 = xq.Ey.*( ...
                    obj.ampSplitRatio(1) * exp(1j*phi1) + ...
                    obj.ampSplitRatio(2) * exp(1j*phi2) );
                y.E = [a1,a2];
            else
                y.E = x.E;
            end
        end
        
        % show how the extinction ratio affects the power and amplitude
        % split ratio
        function scope(~)
            ex = 10:100;
            im = sqrt(1./10.^(ex/10));
            upper = sqrt( 0.5+im );
            lower = sqrt( 1-upper.^2 );
            figure; grid on; hold on
            plot( ex, im, '.-' )
            plot( ex, upper, 'rs-', ex, lower, 'gs-' )
            plot( ex, upper.^2, 'ro-', ex, lower.^2, 'go-' )
            xlabel( 'extinction ratio' )
            ylabel( 'imperfection parameter' )
            legend( 'imperfection', ...
                'amp-upper', 'amp-lower', ...
                'pow-upper', 'pow-lower' )
        end

    end
    
end