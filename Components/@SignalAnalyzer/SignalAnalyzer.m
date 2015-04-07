classdef SignalAnalyzer < Module
    %SignalAnalyzer v1.0, Lingchen Huang, 2015/4/6
    %   Digital signal: Constellation, Spectrum
    %   Electrical Signal: Eyediagram, Spectrum
    %   Optical Signal: Eyediagram of x pol, State of Pol, Spectrum
    
    properties
        ColorMap = 'hot'
        PlotType = '2D Line' % '2D Color' for color eyediagram
    end
    
    methods
        function this = SignalAnalyzer(varargin)
            SetVariousProp(this, varargin{:})
        end
        
        function Processing(obj, x)
            
            if ~isobject(x)
                am = x;
                % digital signal
                % Constellation
                if isreal(am)
                else
                    % normalized field for scatter-plot
                    am_cmp = am.' / max(abs(am));
                    obj.Hist2(am_cmp);
                end
                % Spectrum
                obj.Spectrum(am, 1, 'Digital Signal');
                
            else
                switch x.Name
                    case 'ElectricalSignal'
                        am = x.E;
                        
                        % eye
                        obj.eyeDiag(am_cmp, x.Rs, x.fs / x.Rs, obj.PlotType);
                        
                        % square-law and normalize for evelope detection
                        am_nlz = am / mean(abs(am).^2);
                        % Spectrum
                        obj.Spectrum(am_nlz, x.fs, 'Electrical Signal');
                        
                    case 'OpticalSignal'
                        am = x.Ex;
                        
                        if ~isempty(x.Rs)
                            % eye
                            obj.eyeDiag(am, x.Rs, x.fs / x.Rs, obj.PlotType);
                        end
                        
                        % square-law and normalize for evelope detection
                        am_nlz = am / mean(abs(am).^2);
                        % Spectrum
                        obj.Spectrum(am_nlz, x.fs, 'Optical Signal');
                        
                        % Sphere
                        h = obj.poincareSphere;
                        obj.polarizationAnalyzer(h, 'on', x.E, 'ro');
                end
            end

        end
    end
    
end