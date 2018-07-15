function rxSymbolsOut = Synchronization(rxSymbols, txSymbols, varargin)

p = inputParser;
p.addParameter('verbose', true);
p.addParameter('display', true);
p.addParameter('nSamplePerSymbols', 1);   
p.parse(varargin{:});
Opt = p.Results;

nSamplePerSymbols = Opt.nSamplePerSymbols;

C = xcorr(rxSymbols(1:nSamplePerSymbols:end), txSymbols);

[~, index] = max(C);

rxSymbolsOut = circshift(rxSymbols,  nSamplePerSymbols*(-index+length(txSymbols)));


end

