% symbole_rate: hz
% sps: samples per sym
% modulation_format:dp-qpsk,dp-16qam,dp-32qam,dp-64qam;
% data_length:
% data:moulated data
% msg: msg to be modulated, [0:M-1] M=3,15,31,63

classdef Signal<handle
   
    properties
       symbol_rate;%hz
       sps;
       modulation_format;
       data_length;
       data;
       data_sample;
       msg;
       generate_data;
       %%%%%%%%%%%%%%%%%%%%%%the wdm parameter default is false%%%%%%%%%%
       %%%%%%%%%%%%%%%%%%%%%%if it is true,lambda will be every channel's
       %%%%%%%%%%%%%%%%%%%%%%length,spacing will be the channel space%%%%%
       wdm=false;
       lambda = 1550;
       spacing = 0;
       frequence;
    end
    
    properties(Dependent)
       signal_power; %dbm
       T;%s
       Fs;%hz
       costl;
    end
    
    
    methods
        
        function signal_power = get.signal_power(self)
           temp =  mean(abs(self.data_sample(1,:)).^2)+mean(abs(self.data_sample(2,:)).^2);
           signal_power = 10 * log10((temp * 1000)); %dbm 
      
        end
        
        function set_signal_power(self,p,unit)
            if strcmpi(unit,'dbm')
                self.data_sample = self.data_sample.*sqrt(((10^(p/10))/1000)/sum(mean(abs(self.data_sample).^2,2)));
            end
            
            if strcmpi(unit,'w')
                 self.data_sample = self.data_sample.*sqrt(p/sum(mean(abs(self.data_sample).^2,2)));
            end
            
        end
        
        function costl = get.costl(self)
            if self.modulation_format=="dp-qpsk"
               for i=0:3
                  costl(i+1) = qammod(i,4, 'UnitAveragePower',true);
               end
            end
            
            if self.modulation_format == "dp-16qam"
               for i=0:15
                    costl(i+1) = qammod(i,16, 'UnitAveragePower',true);
               end
            end
            
            if self.modulation_format == "dp-32qam"
               for i=0:31
                    costl(i+1) = qammod(i, 32,'UnitAveragePower',true);
               end
            end
        end
        
        function self = Signal(symbol_rate,sps,modulation_format,data_length,generate_data)
           self.symbol_rate = symbol_rate;
           self.sps = sps;
           self.modulation_format = modulation_format;
           self.data_length = data_length;
           self.generate_data = generate_data;
           self.data_sample = zeros(2,data_length*sps);
           if  ~self.wdm && self.generate_data
               self.modulate();
               
               self.data_sample(1,:) = upsample(self.data(1,:),self.sps);
               self.data_sample(2,:) = upsample(self.data(2,:),self.sps);
                   
           end
          
          
        end
        
        function modulate(self)
            if self.modulation_format == "dp-qpsk"
               self.msg = randi([0,3],2,self.data_length);
               self.data(1,:) = qammod(self.msg(1,:),4, 'UnitAveragePower',true);
               self.data(2,:) = qammod(self.msg(2,:),4, 'UnitAveragePower',true);

            end
            
            if self.modulation_format == "dp-16qam"
               self.msg = randi([0,15],2,self.data_length);
               self.data = qammod(self.msg,16, 'UnitAveragePower',true);
               self.data(1,:) = qammod(self.msg(1,:),16, 'UnitAveragePower',true);
               self.data(2,:) = qammod(self.msg(2,:),16, 'UnitAveragePower',true);

            end
            
            if self.modulation_format == "dp-32qam"
               self.msg = randi([0,31],2,self.data_length);
               self.data = qammod(self.msg,32, 'UnitAveragePower',true);
               self.data(1,:) = qammod(self.msg(1,:),32, 'UnitAveragePower',true);
               self.data(2,:) = qammod(self.msg(2,:),32, 'UnitAveragePower',true);

            end
            
        end
        
        function T = get.T(self)
            T = 1/self.Fs;
        end
        
        function Fs = get.Fs(self)
           Fs = self.symbol_rate*self.sps; 
        end
        
        function down_sample(self,rate)
%             col_number = size(self.data_sample(1,:),2)/rate;
            data_sample_2(1,:) = downsample(self.data_sample(1,:),rate);
            data_sample_2(2,:) = downsample(self.data_sample(2,:),rate);
            self.data_sample = data_sample_2;
        end
    end
end