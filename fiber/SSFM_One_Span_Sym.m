%%%% Fangyuan Zhang, August. 1, 2017
%%%% This code is for single span operation.

function [SignalOut_X, SignalOut_Y] = SSFM_One_Span_Sym(Signal_X, Signal_Y, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fiber parameters

%     c = 3e8;
%     D = Param.D * 1e-12 / (1e-9 * 1e3);
%     Lambda = Param.Lambda;
%     Beta2 = -D * Lambda ^ 2 / (2 * pi * c);
%     L = Param.FiberLength*1e3;
%     DTime = 1/(Param.BaudRate*Param.OverSamp);
%     


p = inputParser;
p.addParameter('msg', 1);
p.addParameter('verbose', true);
p.addParameter('display', true);
p.addParameter('DTime',7.14285714285714e-12 );      % with 35G baund rate and 4 times oversampling rate
p.addParameter('Span_Length', 80e3); % 
p.addParameter('Step_Length', 20);  % 
p.addParameter('Beta2', -2.1668e-26);  %
p.addParameter('Beta3', 0);  %
p.addParameter('Alpha',0.2);  % 
p.addParameter('Gamma', 0.001314390006384);  % with Aeff 80 um^2,f=193.1e12, and n2 = 2.6e-20;
p.addParameter('Launch_Power', 2);
p.addParameter('CUDA', 1);
p.parse(varargin{:});
Opt = p.Results;


Span_Length = Opt.Span_Length;
Step_Length = Opt.Step_Length;
Beta2 = Opt.Beta2;
Beta3 = Opt.Beta3;
Alpha = log(10^(Opt.Alpha/10))/1e3;
Gamma = Opt.Gamma;
Power = 10^(Opt.Launch_Power/10)*0.001; 

DTime = Opt.DTime;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TIME-FREQUENCY VECTORS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Number_of_Samples = length(Signal_X);
% MaxFreq = 0.5/DTime;
% DFreq = 2*MaxFreq/(Number_of_Samples-1);
% 
% VFreq = (-1:Number_of_Samples-2)*DFreq;
% VFreq = VFreq-0.5*max(VFreq);
% VOmeg = 2*pi*VFreq;	

if mod(Number_of_Samples , 2) == 0

    VFreq = [(0:Number_of_Samples/2-1),(-Number_of_Samples/2: -1)] / (Number_of_Samples*DTime) ;
%     VFreq(VFreq<0)  = VFreq(VFreq<0)+1/DTime;
    VOmeg = 2*pi*VFreq;	
else
    VFreq = [(0:(Number_of_Samples-1)/2),(-(Number_of_Samples-1)/2: -1)] / (Number_of_Samples*DTime) ;
%     VFreq(VFreq<0)  = VFreq(VFreq<0)+1/DTime;
    VOmeg = 2*pi*VFreq;	
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CUDA = Opt.CUDA;
if CUDA
    Span_Length = gpuArray(Opt.Span_Length);
    Step_Length = gpuArray(Opt.Step_Length);
    Beta2 = gpuArray(Opt.Beta2);
    Beta3 = gpuArray(Opt.Beta3);
    Alpha = gpuArray(log(10^(Opt.Alpha/10))/1e3);
    Gamma = gpuArray(Opt.Gamma);
    Power = gpuArray(10^(Opt.Launch_Power/10)*0.001); 

end

Pol_Coefficient = 1;
NStep = ceil(Span_Length/Step_Length);
dz = Step_Length;              % step length
Disper = (1i/2)*Beta2*VOmeg.^2*dz+(1i/6)*Beta3*VOmeg.^3*dz;     % Dispersion phase factor

if Step_Length>Span_Length         %step length should be interger times of Span length 
dz_Eff = round(Step_Length/Span_Length)*(1-exp(-Alpha*Span_Length))/Alpha;     
else                               %span length should be interger times of Step length      
dz_Eff = (1-exp(-Alpha*dz))/Alpha;       
end

Nonli =0.5*8/9*1i*Gamma*dz_Eff*Power; %the power is for two polarizations. Manokov equation is used here

% %Normalization
% Signal_X = Signal_X/sqrt(sum(norm(Signal_X)^2)/length(Signal_X));
% Signal_Y = Signal_Y/sqrt(sum(norm(Signal_Y)^2)/length(Signal_Y));

temp_Et_X = Signal_X;
temp_Et_Y = Signal_Y;
% 
% temp_Ft_X = DTime*(fft(ifftshift(temp_Et_X))).*exp(0.5*Disper);
% temp_Et_X = (1/DTime)*fftshift(ifft(ifftshift(temp_Ft_X))); 
% 
% temp_Ft_Y = DTime*fftshift(fft(ifftshift(temp_Et_Y))).*exp(0.5*Disper);
% temp_Et_Y = (1/DTime)*fftshift(ifft(ifftshift(temp_Ft_Y))); 

temp_Ft_X = DTime*(fft((temp_Et_X))).*exp(0.5*Disper);
temp_Et_X = (1/DTime)*(ifft((temp_Ft_X))); 

temp_Ft_Y = DTime*(fft((temp_Et_Y))).*exp(0.5*Disper);
temp_Et_Y = (1/DTime)*(ifft((temp_Ft_Y))); 

% TEMP=[];
for n=1:NStep   
    
      
    Intensity_X = abs(temp_Et_X).^2;
    Intensity_Y = abs(temp_Et_Y).^2;

    %%% Introduction of nonlinear distortion 

    temp_Et_X = exp(-Alpha*dz/2)*temp_Et_X.*exp((Intensity_X+Pol_Coefficient*Intensity_Y).*Nonli);   
    temp_Et_Y = exp(-Alpha*dz/2)*temp_Et_Y.*exp((Intensity_Y+Pol_Coefficient*Intensity_X).*Nonli); 

     if n==NStep-1 %last step to cope with the total link length 
           dz = Span_Length-(NStep-1)*Step_Length;
           dz_Eff = (1-exp(-Alpha*dz))/Alpha;     
           Nonli = 0.5*8/9*1i*Gamma*dz_Eff*Power;  
           Disper_2=Disper;
           Disper = (1i/2)*Beta2*VOmeg.^2*dz+(1i/6)*Beta3*VOmeg.^3*dz;  
    end

  

    if n<(NStep-1)
        Disper_CD=Disper;
    elseif n==NStep-1
        Disper_CD=0.5*(Disper_2+Disper);
    elseif n==NStep
        Disper_CD=Disper/2;
    end

    
    temp_Ft_X = DTime*(fft((temp_Et_X))).*exp(Disper_CD);  %Introduction of choromatic Dispersion 
    temp_Et_X = (1/DTime)*(ifft((temp_Ft_X)));        

    temp_Ft_Y = DTime*(fft((temp_Et_Y))).*exp(Disper_CD);  %Introduction of choromatic Dispersion 
    temp_Et_Y = (1/DTime)*(ifft((temp_Ft_Y)));   




     
% TEMP=[TEMP mean(temp_Et_X)];

end

% figure;
% plot(1:NStep,abs(TEMP));
% xlim([1 30]);


SignalOut_X =gather( temp_Et_X);        
SignalOut_Y = gather(temp_Et_Y);    
end