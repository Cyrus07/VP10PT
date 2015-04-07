function eyeDiag(obj, data, symrate, nsamp, type)
% creat an eye_scope and plot
eyeDiag = commscope.eyediagram;
eyeDiag.SamplesPerSymbol    = nsamp;
eyeDiag.SamplingFrequency   = nsamp*symrate;
eyeDiag.PlotType            = type;
eyeDiag.AmplitudeResolution = 0.01;
eyeDiag.NumberOfStoredTraces= 400;
eyeDiag.ColorScale          = 'Log';
eyeDiag.RefreshPlot         = 'on';
eyeDiag.SymbolsPerTrace     = 4;

if isreal(data(1))
    eyeDiag.MaximumAmplitude  = 1.1;
    eyeDiag.MinimumAmplitude  = -0.1;
    update(eyeDiag, data);
else
    eyeDiag.OperationMode     = 'Complex Signal';
    eyeDiag.MaximumAmplitude  = 1.1;
    eyeDiag.MinimumAmplitude  = -1.1;
    update(eyeDiag, data./mean(abs(data)));
end

if strcmpi(obj.PlotType,'2D Color')
    % specify the colormap of the eye_scope
    cmap = colormap(obj.ColorMap);
    % black backgroup
    cmap(1,:) = [0 0 0];
    plot(eye, cmap)
end
end