function ce_reverse = CEISTA(x, nfft, ngi, nblock, TrainMat)

if size(x,2) == 1
    mat = reshape(x(:,1), nfft+ngi, []);
    mat = mat(1:nfft, :);
    mat = fft(mat,[],1);
    hMat = TrainMat{1} ./ mat;
    hPhaserVec = hMat(:,1)' * hMat;
    hPhaserVec = hPhaserVec./abs(hPhaserVec);            
	hMat = hMat .* repmat(conj(hPhaserVec),  size(hMat, 1), 1);   
    ce_reverse = mean(hMat, 2);
%     amp = abs(hMat);plot(var(amp.'));
%     phi = angle(hMat);plot(var(phi.'));
%     ce_reverse = mean(amp,2).*exp(1i*mean(phi,2));
    
elseif size(x,2) == 2
    mat1 = reshape(x(:,1), nfft+ngi, []);
    mat1 = mat1(1:nfft, :);
    mat1 = fft(mat1,[],1);
    mat2 = reshape(x(:,2), nfft+ngi, []);
    mat2 = mat2(1:nfft, :);
    mat2 = fft(mat2,[],1);
    % need refer to "MIMO OFDM channel estimate"
    for n = 1:nblock
        for k = 1:nfft
            ce_reverse(k,:,:,n) = [TrainMat{1}(k,2*n-1:2*n);TrainMat{2}(k,2*n-1:2*n)] ...
                / [mat1(k,2*n-1:2*n);mat2(k,2*n-1:2*n)];
        end
        for k = 1:nfft
            ce_reverse(k,:,:,n) = squeeze(ce_reverse(k,:,:,n)) ...
                / (exp(1i*angle(ce_reverse(3,1,1,n)))*eye(2));
        end
    end
    ce_reverse = mean(ce_reverse,4);
    
end

end