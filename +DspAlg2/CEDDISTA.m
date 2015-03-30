function ce_reverse = CEDDISTA(x, pol, nfft, ngi, nblock, Seq, J)

if pol == 1
    mat = reshape(x(:,1), nfft+ngi, []);
    mat = mat(1:nfft, :);
    mat = fft(mat,[],1);
    for n = 1:nblock
        ce_reverse(:,n) = Seq ./ mat(:,n);
    end
%     amp = abs(ce_reverse);plot(var(amp.'));
%     phi = angle(ce_reverse);plot(var(phi.'));
%     ce_reverse = mean(amp,2).*exp(1i*mean(phi,2));
    ce_reverse = mean(ce_reverse,2);

    
elseif pol == 2
    mat1 = reshape(x(:,1), nfft+ngi, []);
    mat1 = mat1(1:nfft, :);
    mat1 = fft(mat1,[],1);
    mat2 = reshape(x(:,2), nfft+ngi, []);
    mat2 = mat2(1:nfft, :);
    mat2 = fft(mat2,[],1);
    for n = 1:nblock
        for k = 1:nfft
            ce_reverse(k,:,:,n) = (Seq(k,1)*J) ...
                / [mat1(k,2*n-1:2*n);mat2(k,2*n-1:2*n)];
        end
    end
    ce_reverse = mean(ce_reverse,4);
    
end

end