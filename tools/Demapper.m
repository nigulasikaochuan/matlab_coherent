function [rxBits, decSymbols] = Demapper(rxSymbols, cnstl)

M = log2(length(cnstl));

nSymbols = size(rxSymbols,2);

cnstlMat = repmat(cnstl, nSymbols,1);

nPol = length(rxSymbols(:,1));

for iPol = 1:nPol
    
    tmp = bsxfun(@minus, cnstlMat.', rxSymbols(iPol, :));
    eudDist = real(tmp).^2 + imag(tmp).^2;
    
    [~,index] = min(eudDist);
    
    decSymbols(iPol, :) = cnstl(index);
    
    txBits_word = de2bi(index-1, M);
    
    rxBits(iPol,:) = reshape(txBits_word.', 1, numel(txBits_word));
 
end

end

