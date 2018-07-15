classdef Edfa < handle
%     Edfa
%  property:
%       Gain_db
%       Nf
%       Wavelength .-->m
%       Mode 
%       outPower---->use dbm
% There are two Mode of EDFA,ConstantPower and ConstantGain, if Mode set to
% ConstantPower, the outPower property must be set. all units in this file  should use international standard 
    properties
        Gain_db %db
        Nf %db
        Wavelength %m
        Mode %ConstantPower or ConstantGain
        outPower %if mode is ConstantPower,this proper should be set
    end
    
    properties (Dependent)
        Gain_lin;
        One_ase;
        nsp;
    end
    
    properties (Constant)
        h = 6.62606957e-34; % Planck
        q = 1.60217657e-19; % electron charge
        c = 299792458;      % speed of light
    end
    
    methods
        function One_ase = get.One_ase(self)
            One_ase = (self.Gain_lin *10^(self.Nf/10)-1)/2*(self.h*self.c/self.Wavelength);
        end
        
        function Gain_lin = get.Gain_lin(self)
            Gain_lin = 10^(self.Gain_db/10);
        end
        
        function nsp = get.nsp(self)
            nsp = 1/2*10^(self.Nf/10);
        end
        
        function self = Edfa(param)
            self.Mode = param.Mode;
            self.Nf = param.Nf;
            self.Wavelength = param.Wavelength;
            
            if strcmpi(self.Mode,'ConstantPower')
                self.outPower = param.outPower;
            else
                self.Gain_db = param.Gain;
            end
        end
        
        function prop(self,signal)
         
            N = length(signal.data_sample);
            
            if strcmpi(self.Mode,'ConstantPower')
                param.unit='dbm';
                power = power_meter(signal.data_sample,param);
            
                self.Gain_db = -(power - self.outPower);
            end
             
%             noise = wgn(size(signal.data_sample,1), size(signal.data_sample,2), self.One_ase*signal.Fs, 'linear', 'complex');
            W = 0.5*sqrt( self.One_ase*signal.Fs)*(randn(2, N) + 1j*randn(2, N));
            signal.data_sample = sqrt(self.Gain_lin) * signal.data_sample + W;
            
            
        end
    end
end
