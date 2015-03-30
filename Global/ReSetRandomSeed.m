function ReSetRandomSeed(RandomNumberSeedLD, rngCurrState)

if RandomNumberSeedLD
    RandStream.setGlobalStream(rngCurrState);
end
