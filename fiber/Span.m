classdef Span < handle
%             alpha:db/km ,default:0.2
%             length:km default:80
%             D:Fiber dispesion coefficients [ps/nm/km] default:17
%             S:Fiber dispesion slope [ps/nm^2/km] default:0
%             gamma:   Fiber nonlinear coefficients [W^-1*km^-1] default:1.2

    properties
       alpha = 0.17;
       D = 20.1;
       S = 0;
       length =120;
       gamma=0.8;
       lambda=1550;
       beta3 = 0;
    end
    
    properties(Constant)
        c=3e8;
    end
    
    properties(Dependent)
       beta2; % s^2/km
       alpha_lin;   %1/km
    end
    
    methods 
        function alpha_lin =get.alpha_lin(self)
              alpha_lin = log(10^(self.alpha/10)); %1/km
        end
        
        function beta2 = get.beta2(self)
            beta2 = -self.D*(self.lambda*1e-12)^2/(2*pi*self.c*1e-3);
        end
        
        function self = Span(param)
            if param.default == false
                self.alpha = param.alpha;
                self.D = param.D;
                self.S = param.S;
                self.gamma = param.gamma;
                fiber_type = param.fiber_type;
                self.lambda = param.lambda;
                self.length = param.length;
            else
                return;
            end
           
            
            if fiber_type == 1
                 self.D=16.8;
               
               
                 self.alpha = 0.2;
               
%                  Aeff = 79.6e-12;
%                  self.gamma = 2*pi*n2*f/c/Aeff;
            end
        end
        
        function prop(self,signal)
            [signal.data_sample(1,:), signal.data_sample(2,:)] = SSFM_One_Span_Sym2( signal.data_sample(1,:), signal.data_sample(2,:),'DTime',1/signal.Fs,'Span_Length',self.length*1e3,'Beta2',self.beta2*1e-3,'Beta3',self.beta3,'Alpha',self.alpha,'Gamma',self.gamma*1e-3,'Launch_Power',signal.signal_power);
       
        end
        
    end

end

