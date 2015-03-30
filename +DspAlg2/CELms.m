function ce_reverse = CELms(x, pol, nfft, ngi, nblock, Seq, J)
%   R = C*T*P + N
%   C^-1 * R + N = T * P
nu = 0.1;

if pol == 1
    mat = reshape(x(:,1), nfft+ngi, []);
    mat = mat(1:nfft, :);
    mat = fft(mat,[],1);
    
    n = 1;
    phi = 0;
    ce_reverse(:,n) = conj(Seq ./ mat(:,n));
    for n = 2:nblock
        tmp = conj(ce_reverse(:,n-1)) .* mat(:,n) ./Seq;
        phi(n) = exp(1i*angle(sum(tmp(2:end))));
        e(:,n) = Seq - conj(ce_reverse(:,n-1)) .* mat(:,n) / phi(n);
        ce_reverse(:,n) = ce_reverse(:,n-1) + nu * conj(e(:,n)) .* mat(:,n);
    end
    ce_reverse = conj(ce_reverse(:,end));
    figure;plot(angle(phi));
    figure;plot(mean(abs(e(3:end-1,:)),1));
    
elseif pol == 2
    mat1 = reshape(x(:,1), nfft+ngi, []);
    mat1 = mat1(1:nfft, :);
    mat1 = fft(mat1,[],1);
    mat2 = reshape(x(:,2), nfft+ngi, []);
    mat2 = mat2(1:nfft, :);
    mat2 = fft(mat2,[],1);
    
    n = 1;
    phi = [0;0];
    for k = 1:nfft
        ce_reverse(k,:,:,n) = [TrainVec{1}(k,2*n-1:2*n);TrainVec{2}(k,2*n-1:2*n)] ...
            / [mat1(k,2*n-1:2*n);mat2(k,2*n-1:2*n)];
    end
    for n = 2:nblock
        for k = 1:nfft
            tmp(k,:,1) = squeeze(ce_reverse(k,:,:,n-1))*[mat1(k,2*n-1);mat2(k,2*n-1)].*conj([TrainVec{1}(k,2*n-1);TrainVec{2}(k,2*n-1)]);
            tmp(k,:,2) = squeeze(ce_reverse(k,:,:,n-1))*[mat1(k,2*n);mat2(k,2*n)].*conj([TrainVec{1}(k,2*n);TrainVec{2}(k,2*n)]);
        end
        phi(1,n) = exp(1i*angle(sum(tmp(2:end,:,1)*abs(J(:,1)))));
        phi(2,n) = exp(1i*angle(sum(tmp(2:end,:,2)*abs(J(:,2)))));
        for k = 1:nfft    % supposing phase noise for two pol at the same time is the same
            e(k,:,:,n) = [TrainVec{1}(k,2*n-1:2*n);TrainVec{2}(k,2*n-1:2*n)]...
                - squeeze(ce_reverse(k,:,:,n-1)) ...
                * [mat1(k,2*n-1:2*n);mat2(k,2*n-1:2*n)] ...
                / [phi(1,n) 0;0 phi(2,n)];
            ce_reverse(k,:,:,n) = squeeze(ce_reverse(k,:,:,n-1)) ...
                + nu * conj([mat1(k,2*n-1:2*n);mat2(k,2*n-1:2*n)]) * squeeze(e(k,:,:,n-1));
        end
    end
    ce_reverse = ce_reverse(:,:,:,end);
    figure;plot(angle(phi(1,:)));
    figure;plot(mean(abs(squeeze(e(3:end-1,1,1,:))),1));
end
close; close;
end