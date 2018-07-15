clc;
clear all;

sig1 = Signal(35e9,4,"dp-qpsk",2^16,true);

param.default=true;
span_obj = Span(param);


param.roll_off=0.2;
param.span=6;
param.sps=4;
wav = Wave(param);
wav.prop(sig1);
pram.Gain = 16;
pram.Nf = 5;
pram.Mode = 'heihei';
pram.Wavelength = 1550e-9;
edfa= Edfa(pram);
wav = Wave(param);
power = 2;
sig1.set_signal_power(power,"dbm");

before = sig1.data_sample;
for i = 1:1
    i
    span_obj.prop(sig1);
    edfa.prop(sig1);
    sig1.data_sample(1,:) = CD_Compensation(sig1.data_sample(1,:),sig1.T,span_obj.length,span_obj.beta2);
    sig1.data_sample(2,:) = CD_Compensation(sig1.data_sample(2,:),sig1.T,span_obj.length,span_obj.beta2);
end
% after_cd(1,:) = CD_Compensation(sig1.data_sample(1,:),sig1.T,span_obj.length*20,span_obj.beta2);
% after_cd(2,:) = CD_Compensation(sig1.data_sample(2,:),sig1.T,span_obj.length*20,span_obj.beta2);

% after_cd_d(1,:) = downsample(sig1.data_sample(1,:),4);
% after_cd_d(2,:) = downsample(sig1.data_sample(2,:),4);
% 
% after_signl = Signal(35e9,4,"dp-qpsk",2^16,false);
% after_signl.data_sample = after_cd_d;
% after_signl.set_signal_power(2,'w');
% x_recv = Synchronization(after_signl.data_sample(1,:),sig1.data(1,:));
% y_recv = Synchronization(after_signl.data_sample(2,:),sig1.data(2,:));