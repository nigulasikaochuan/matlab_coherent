clc;
clear all;
sig = Signal(32e9,4,"dp-qpsk",2^4,true);

param.span=6;
param.sps = 4;
param.roll_off = 0.2;
wav = Wave(param);
wav.prop(sig);
Wave.spec(sig);

wav.matched_filter(sig);

msg(1,:) = qamdemod(downsample(sig.data_sample(1,:),4),4);


% 
% pram.default=true;
% span = Span(pram);
% param.Gain = 16;
% param.Nf = 5;
% param.Wavelength=1550e-9;
% param.Mode="heiehi";
% edfa = Edfa(param);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sig.set_signal_power(2,'dbm');
% before = sig.data_sample;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% for i=1:1
%     
%     span.prop(sig);
%     edfa.prop(sig);
% end
