function [x_sample,y_sample] = decombine(signal,center_baud_rate,rool_off)
    
    cut_off_frequence = center_baud_rate/2*(1+rool_off);
    
    freq_df = signal.sps*signal.symbol_rate/length(signal.data_sample(1,:));
    
    if mod(length(signal.data_sample(1,:)),2) == 0
        
        freq = [(0:length(signal.data_sample(1,:))/2-1),(-length(signal.data_sample(1,:))/2: -1)] *freq_df ;
        
    else
        
        freq = [(0:(length(signal.data_sample(1,:))-1)/2),(-(length(signal.data_sample(1,:))-1)/2: -1)]*freq_df;
    end
    
    xpol_freq = fft(signal.data_sample(1,:));
    ypol_freq = fft(signal.data_sample(2,:));
    
    xpol_freq(freq>cut_off_frequence)=0;
    xpol_freq(freq<-cut_off_frequence)=0;
    
    ypol_freq(freq>cut_off_frequence)=0;
    ypol_freq(freq<-cut_off_frequence)=0;
    
    x_sample = ifft(xpol_freq);
    y_sample = ifft(ypol_freq);
    


end