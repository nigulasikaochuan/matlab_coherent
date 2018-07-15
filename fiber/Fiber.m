classdef Fiber < handle
   
    properties
       spans;
       is_edfa;
       edfas = 0;
    end
    
    methods
        function self = Fiber(param,spans,is_edfa,edfas)
           self.spans = param.spans;
           if param.is_edfa
             self.edfas=param.edfas;
           end
        end
        
        function prop(self,signal)
           
           for i = 1:size(self.spans,1)
               self.spans(i).prop(signal);
               
               if self.is_edfa
                   self.edfas(i).prop(signal);
               end
               
           end
           
        end
        
    end
    
    
    
end