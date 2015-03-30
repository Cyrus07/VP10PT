function [y df] = blind_freq_search(x,symrate,mn,M,bs)



test_phi = (0:M-1)/M*pi/2;

x = DspAlg.Normalize(x,mn);

tic
for pol = 1:size(x,2)
    xp = reshape(x(:,pol),bs,[]);
    yp = zeros(size(xp));
    
    for b = 1:size(xp,2)
        data_mat = repmat(xp(:,b),1,M);
        phas_mat = exp(1j*repmat(test_phi,bs,1));
        
        test_freq = -200e6:10e6:200e6;
        test_phas = test_freq*2*pi/symrate;
        for k = 1:length(test_freq)
            phi_vec = test_phas(k)*(1:bs);
            freq_mat = exp(1j*repmat(phi_vec(:),1,M));
            xp_tmp = data_mat.* phas_mat.* freq_mat;
            xd = DspAlg.slicer(xp_tmp,mn);
            dist_phi = mean(abs(xp_tmp-xd).^2);
            [dist_corse(k) idx_phi(k)] = min(dist_phi);
        end
        [tmp idx_freq] = min(dist_corse);
        rot_phas = test_phi(idx_phi(idx_freq));
        rot_freq = test_phas(idx_freq);
        
        new_freq = test_freq(idx_freq)+(-30e6:1e6:30e6);
        new_phas = new_freq*2*pi/symrate;
        for k = 1:length(new_freq)
            phi_vec = new_phas(k)*(1:bs);
            freq_mat = exp(1j*repmat(phi_vec(:),1,M));
            xp_tmp = data_mat.* phas_mat.* freq_mat;
            xd = DspAlg.slicer(xp_tmp,mn);
            dist_phi = mean(abs(xp_tmp-xd).^2);
            [dist_fine(k) idx_phi(k)] = min(dist_phi);
        end
        [tmp idx_freq] = min(dist_fine);
        rot_phas = test_phi(idx_phi(idx_freq));
        rot_freq = new_phas(idx_freq);
        
        
        yp(:,b) = xp(:,b).* exp(1j*rot_phas).* exp(1j*rot_freq*(1:bs).');
        df(b) = new_phas(idx_freq);
    end
    y(:,pol) = yp(1:end);
end
toc


