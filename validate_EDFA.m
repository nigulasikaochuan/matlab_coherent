clc;
clear all;
sig1 = Signal(35e9,4,"dp-qpsk",2^16,true);

pw.sps=6;
pw.span=6;
pw.roll_off=0.2;

wav = Wave(pw);
wav.prop(sig1);

param.unit='dbm';

power_meter(sig1.data_sample,'dbm')
scatterplot(sig1.data(1,:))
%%%%%%%%%%%%%%%%%set edfa%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

param.default=true;

param.Gain = 24;
param.Nf=5;
param.Mode='aaa';
param.Wavelength = 1550e-9;
edfa = Edfa(param);
span=Span(param);
span.prop(sig1);
edfa.prop(sig1);
power_meter(sig1.data_sample,'dbm')
