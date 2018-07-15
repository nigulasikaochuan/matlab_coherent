function theta = vitvit( s, P, M, k, applyunwrap)
% s is signal
% p
% m 
% k vertibi alg average
% applyunwrap bool value

s = s.';

L = length(s);
% Phase -> Phase * M
% Amplitude -> Amplitude ^ P
if P == M
    s = s .^ P;
else
    s = abs(s).^P .* fastexp( angle( s.^ M ) );
end
if k>0
N = 2*k + 1;
if N<L
    Smoothing_Filter = fft( ones(N, 1) / N , L ) * ones(1,size(s,2));
    s = ifft( fft(s,L) .* Smoothing_Filter );
else
    slong = repmat( s, ceil(N / L), 1 );
    Smoothing_Filter = fft( ones(N, 1) / N , ceil(N / L).*L ) * ones(1,size(s,2));
    slong = ifft( fft(slong) .* Smoothing_Filter );
    s = slong(1:L,:);
end
end
if applyunwrap
    theta = unwrap( angle(s) ) / M;
else
    theta = angle( s ) / M;
end
theta = theta.';
return