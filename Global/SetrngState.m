function rngCurrState = SetrngState(rngState)

if ~isempty(rngState)
    % record current random number generator state
    rngCurrState = RandStream.getGlobalStream;
    % set target random number generator state
    RandStream.setGlobalStream(rngState);
else
    rngCurrState = [];
end
