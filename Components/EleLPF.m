classdef EleLPF < Electrical_
    %EleLPF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Bandwidth   = 50e9;
        FilterOrder = 5;
        FilterShape = 'Bessel';
        FilterDomain = 'FD'
    end
    properties (GetAccess = protected)
        Input
    end
    properties (SetAccess = protected)
        Output
    end
    methods
        %%
        function obj = EleLPF(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function Processing(obj)
            for n = 1:length(obj.Input)
                Check(obj.Input{n}, 'ElectricalSignal');
                obj.Output{n} = Copy(obj.Input{n});
                if ~obj.Active || obj.Bandwidth >= 50e9
                    obj.Output{n}.E = obj.Input{n}.E;
                    continue
                end
                if isempty(obj.Input{n}.E)
                    continue
                end
                switch obj.FilterDomain
                    case 'FD'
                        % frequency domian implementation
                        N = length(obj.Input{n}.E);
                        f = [0:N/2-1, -N/2:-1]/N*obj.Input{n}.fs;
                        bw = obj.Bandwidth;
                        Hf = myfilter('bessel5',f,bw);
                        Hf2 = exp(1i*2.427410702/bw*f).';
                        Hf = Hf.*Hf2;
                        rInput = real(obj.Input{n}.E);
                        iInput = imag(obj.Input{n}.E);
                        rOutput = real(ifft(fft(rInput).*Hf));
                        iOutput = real(ifft(fft(iInput).*Hf));
                        obj.Output{n}.E = rOutput + 1i*iOutput;
                    case'TD'
                        % time domian implementation
                        bw = obj.Bandwidth/(obj.Input{n}.fs/2);
                        switch lower(obj.FilterShape)
                            % doc
                            case 'chebyshev1'
                                [b, a] = cheby1(obj.FilterOrder, 0.1, bw, 'low');
                            case 'chebyshev2'
                                [b, a] = cheby1(obj.FilterOrder, 0.1, bw, 'low');
                            case 'bessel'
                                [b,a] = besself(obj.FilterOrder,bw*2*pi/0.61568541166758);
                                [b,a] = impinvar(b,a,2);
                            case 'gaussian'
                                N = 16;
                                b = gaussfir(bw,N,1);
                                while b(1)>1e-4
                                    N = N*2;
                                    b = gaussfir(bw,N,1);
                                end
                                while b(1)<1e-6
                                    N = N/2;
                                    b = gaussfir(bw,N,1);
                                end
                                a = 1;
                            case 'example'
                        end
                        [h,~] = freqz(b,a);
                        PhiH = unwrap(angle(h))/2/pi*length(h);
                        Lnth = 10;
                        tVec = (0:Lnth-1).';
                        p = polyfit(tVec,PhiH(1:Lnth),1);
                        % not clear why it should be multiply by 2
                        FiltDelay = round(-p(1)*2);
                        VecOutput = filter(b, a, [obj.Input{n}.E; zeros(FiltDelay,1)]);
                        obj.Output{n}.E = VecOutput(FiltDelay+1:end);
                    otherwise
                        warning('INVALID LPF IMPLEMENTATION DOMAIN');
                end
            end
        end
        
    end
    
end
