function [y, phi] = PhaseEstimatorFreqDomian(x, obj)
%   C^-1 * R + N = T * P

if  ndims(x) == 2
    for n = 1:size(x,2)
        phi(n) = exp(-1i*angle(obj.PilotSequence' * x(obj.IndPilot,n)));
        cs(:,n) = x(obj.IndSubCarr,n) * phi(n);
    end
    y = cs(:);
    
elseif  ndims(x) == 3
    for n = 1:size(x,3)
        phi(:,n) = exp(-1i*angle(x(:,obj.IndPilot,n)*conj(obj.PilotSequence)));
        cs(:,:,n) = diag(phi(:,n)) * x(:,obj.IndSubCarr,n);
    end
    y(:,1) = reshape(cs(1,:,:),[],1);
    y(:,2) = reshape(cs(2,:,:),[],1);
end

end