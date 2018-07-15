% pulse shape using rcosdesign

classdef Wave<handle
   
    properties
       roll_off
       sps;
       span;
       h;
    end
    
    methods(Static)
       function spec(signal)
           periodogram(signal.data_sample(1,:),[],length(signal.data_sample(1,:)),'center',signal.sps*signal.symbol_rate); 
        end 
    end
    
    methods
        
        function self = Wave(param)
            self.sps=param.sps;
            self.span =param.span;
            self.roll_off = param.roll_off;
          
%             self.design(param.pulse_shape);
            self.h = rcosdesign(self.roll_off,self.span,self.sps,'sqrt');
           
        end
        
        function design(self,shape)
            if strcmpi(shape,'rrc')
                  self.h = rcosdesign(self.roll_off,self.span,self.sps,'sqrt');
                  self.h = self.h/max(self.h);
            end
            
            if strcmpi(shape,'rc')
                  self.h = rcosdesign(self.roll_off,self.span,self.sps,'sqrt');
                  self.h = self.h/max(self.h);
            end
        end
        
        function prop(self,signal)
           
            delay = self.span/2*self.sps;
%             w = 2*pi/length(signal.data_sample(1,:))*(0:length(signal.data_sample)-1);%0-2*pi,digital angular frequence
            %filter conv will lead to group delay, so use fft and freqz to
%             %avoid this problem by multiply a expeon. factor
%             signal.data_sample(1,:) = freqz(self.h,1,w).*fft(signal.data_sample(1,:)).*exp(1j*w*delay);
%             signal.data_sample(2,:) = freqz(self.h,1,w).*fft(signal.data_sample(2,:)).*exp(1j*w*delay);
%             
%             signal.data_sample(1,:) = ifft(signal.data_sample(1,:));
%             signal.data_sample(2,:) = ifft(signal.data_sample(2,:));
           tempx = upfirdn(signal.data(1,:),self.h,signal.sps,1);
           tempy = upfirdn(signal.data(2,:),self.h,signal.sps,1);
           tempx = circshift(tempx,-delay);
           tempy = circshift(tempy,-delay);
           signal.data_sample(1,:) = tempx(1:signal.sps*signal.data_length);
           signal.data_sample(2,:) = tempy(1:signal.sps*signal.data_length);
        end
        
        function matched_filter(self,signal)
           delay = self.span/2*self.sps;
           tempx = upfirdn(signal.data_sample(1,:),self.h,1,1);
           tempy = upfirdn(signal.data_sample(2,:),self.h,1,1);
           tempx = circshift(tempx,-delay);
           tempy = circshift(tempy,-delay);
           signal.data_sample(1,:) = tempx(1:signal.sps*signal.data_length);
           signal.data_sample(2,:) = tempy(1:signal.sps*signal.data_length);
        end
        
    end
end