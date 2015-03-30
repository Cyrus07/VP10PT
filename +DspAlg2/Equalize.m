function y = Equalize(x1,x2)
% x1 represents channel estimate of dimeansion (k,2)
% x2 represents data of dimension (k,2,2)
% the function realize output is the same as the three line codes below,
% with optimized processing interval.
%
% for k = 1:size(x1,1)
%     y(k,:) = squeeze(x1(k,:,:))*x2(k,:).';
% end

y = squeeze(sum(bsxfun(@times,x2,permute(x1,[1 3 2])),2));

end