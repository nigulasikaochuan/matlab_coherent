function signal_wdm =  combine_sig(signal,space,center_frequence)
 
    ch_number = size(signal,2);
    
    delta_fre = space*(-(ch_number-1)/2:-1);
    delta_fre = [delta_fre,0,space*(1:(ch_number-1)/2)];
    
    data_sample = zeros(2,size(signal(1).data_sample,2));
    t = signal(1).T*(0:length(signal(1).data_sample(1,:))-1);
    
    for i=1:length(signal)
       data_sample = data_sample + signal(i).data_sample.*exp(1j*2*pi*delta_fre(i).*t); 
       modulation_format(i) = signal(i).modulation_format;
    end
    
    
 
    signal_wdm = Signal(signal(1).symbol_rate,signal(1).sps,modulation_format,signal(1).data_length,false);
    signal_wdm.wdm=true;
    signal_wdm.frequence = center_frequence + delta_fre;
    signal_wdm.data_sample = data_sample;
    signal_wdm.spacing = space;
end