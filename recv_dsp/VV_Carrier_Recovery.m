function Symbols_Out = VV_Carrier_Recovery(Symbols_In,N)
    
    Symbols_Normal = Symbols_In./abs(Symbols_In);
    Symbols_Num = length(Symbols_In);
    n = 0;
    Ave_Power_Symbols = zeros(1,Symbols_Num);
    theta = zeros(1,Symbols_Num);
    
    Power_Symbols = -Symbols_Normal.^4;
%     theta(1) = pi;
    temp = 0;
%     n = 2;
    for i = 2:Symbols_Num
        
        Ave_Power_Symbols(i) = sum(Power_Symbols(max(i-N,1):min(i+N,Symbols_Num)))/(2*N+1);
        theta(i) = angle(Ave_Power_Symbols(i))/4;
        
        if i > 1
            if abs(theta(i)-temp) <= pi/4
                n = n+0;
            elseif theta(i)-temp < -pi/4
                n = n+1;
            elseif theta(i)-temp > pi/4
                n = n-1;
            end
        end
        
        temp = theta(i);
        theta(i) = theta(i)+pi/2*n;
                       
    end
    
    Symbols_Out = Symbols_In.*exp(-1j*theta);
     figure;plot(theta);   

end

