function y = Trigger(x,TriLevel,Points)

NumBlocks = ceil(size(x,1)/Points);
x2 = zeros(NumBlocks*Points,size(x,2));
x2(1:size(x,1),1:size(x,2)) = x;
x3 = reshape(sum(x2.*conj(x2),2),Points,[]);
PowerEnvelope = mean(x3,1);
ind = find(PowerEnvelope>max(PowerEnvelope)*TriLevel,1);
y = x((ind-2)*Points+1:end,:);

end