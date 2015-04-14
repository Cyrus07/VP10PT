classdef OpticalCombiner < Optical_
    %OpticalCombiner N-by-1 optical power combiner
    %   Ideal optical power combiner with zero loss and arbitary number of
    %   inputs. All the inputs should have the same Sampling Frequency.
        
    methods
        function obj = OpticalCombiner(varargin)
            SetVariousProp(obj, varargin{:})
        end
    end
    
    methods (Static)
        function y = Processing(varargin)
            
            y = Copy(varargin{1});
            
            % time vector
            tv = (0:length(varargin{1}.E)-1).'/varargin{1}.fs;
            % take the 1st cf as the reference
            fs = varargin{1}.fs;
            f1 = varargin{1}.fc;
            A = 0;
            
            for k = 1:length(varargin)
                
                if varargin{k}.fs ~= fs
                    error('OPTICALCOMBINER::inputs must have same sampling rate')
                end

                fk = varargin{k}.fc;
                % sum the complex envelope, extracting the common factor exp(i*w1*t)
                if fk == f1
                    A = A + varargin{k}.E;
                elseif fk~= f1
                    A = A + exp(1j*2*pi*(fk-f1)*tv)*ones(1,2).*varargin{k}.E;
                end
            end
            
            y.E = A / sqrt(length(varargin));
        end
    end
    
end

