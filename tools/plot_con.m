function plot_con(signal)

nPol = length(signal.data(:,1));

for iPol = 1:nPol
    
    figure;
    plot(real(signal.data(iPol,:)), imag(signal.data(iPol,:)),'.');
    
end

end

