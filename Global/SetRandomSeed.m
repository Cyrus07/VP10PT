function rngCurrState = SetRandomSeed(RandomNumberSeed)

if isempty(RandomNumberSeed)
    RandomNumberSeed = 0;
end
% record current random number generator state
rngCurrState = RandStream.getGlobalStream;
s = RandStream('mt19937ar','Seed',RandomNumberSeed);
RandStream.setGlobalStream(s);

