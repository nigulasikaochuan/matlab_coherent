function power = power_meter(Ein,unit)
   
    if size(Ein,1) == 1
       power = mean(abs(Ein).^2); 
    end
    
    if size(Ein,1) == 2
       power = mean(abs(Ein(1,:)).^2)+mean(abs(Ein(2,:)).^2); 
    end
    
    if strcmpi(unit,'dbm')
            
        power  =  10*log10(power/1e-3);
    end
    
 end