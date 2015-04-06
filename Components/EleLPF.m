classdef EleLPF < Electrical_
    %EleLPF v1.0, Lingchen Huang, 2015/3/16
    
    properties
        Bandwidth   = 50e9;
        FilterOrder = 5;
        FilterShape = 'Bessel';
        FilterDomain = 'FD'
    end
    methods
        %%
        function obj = EleLPF(varargin)
            SetVariousProp(obj, varargin{:})
        end
        %%
        function y = Processing(obj, x)
            for n = 1:length(x)
                Check(x{n}, 'ElectricalSignal');
                y{n} = Copy(x{n});
                if ~obj.Active || obj.Bandwidth >= 50e9
                    y{n}.E = x{n}.E;
                    continue
                end
                if isempty(x{n}.E)
                    continue
                end
                switch obj.FilterDomain
                    case 'FD'
                        % frequency domian implementation
                        N = length(x{n}.E);
                        f = [0:N/2-1, -N/2:-1]/N*x{n}.fs;
                        bw = obj.Bandwidth;
                        Hf = myfilter('bessel5',f,bw);
                        Hf2 = exp(1i*2.427410702/bw*f).';
                        Hf = Hf.*Hf2;
                        rInput = real(x{n}.E);
                        iInput = imag(x{n}.E);
                        rOutput = real(ifft(fft(rInput).*Hf));
                        iOutput = real(ifft(fft(iInput).*Hf));
                        y{n}.E = rOutput + 1i*iOutput;
                    case'TD'
                        % time domian implementation
                        bw = obj.Bandwidth/(x{n}.fs/2);
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
                        VecOutput = filter(b, a, [x{n}.E; zeros(FiltDelay,1)]);
                        y{n}.E = VecOutput(FiltDelay+1:end);
                    otherwise
                        warning('INVALID LPF IMPLEMENTATION DOMAIN');
                end
            end
        end
        
    end
    
end
