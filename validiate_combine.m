clc;
clear all;
fs = 280e9;

sig1 = Signal(35e9,8,"dp-qpsk",2^18,true);
sig2 = Signal(20e9,14,"dp-qpsk",2^18,true);
sig3 = Signal(16e9,18,"dp-qpsk",2^18,true);
%%%%%%%%%%%%%%%%%%%%%%%%generate three wave object%%%%%%%%%%%%%%%%%%%%%%%%%
param.span = 6;
param.sps = 8;
param.roll_off = 0.2;
param.plot=false;
wave1 = Wave(param);
param.sps = 14;
wave2 = Wave(param);
param.sps = 18;
wave3 = Wave(param);
%%%%%%%%%%%%%%%%%%%%%%%%pulse shaping%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wave1.prop(sig1);

wave2.prop(sig2);
plot_con(sig1)
wave3.prop(sig3);

%%%%%%%%%%%%%%%%%%%%%%%%pad zero ,ensuring the same size of three channel%%
max_length = size(sig3.data_sample,2);
sig2.data_sample = [sig2.data_sample,zeros(2,max_length-size(sig2.data_sample,2))];
sig1.data_sample = [sig1.data_sample,zeros(2,max_length-size(sig1.data_sample,2))];


sig = [sig1,sig2,sig3];
%%%%%%%%%%%%%%%%%%%%%%% Frequence multiplex and plot the spectrum of the
%%%%%%%%%%%%%%%%%%%%%%% combined signal%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sig_wdm = combine_sig(sig,50e9,193.1e12);
Wave.spec(sig_wdm)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%decombine%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x_sample,y_sample] = decombine(sig_wdm,20e9, 0.2);

signl2_decom = Signal(20e9,14,"dp-qpsk",2^18,false);
signl2_decom.data_sample = [x_sample;y_sample];
Wave.spec(signl2_decom);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%match_Filter%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
signl2_decom.data_sample = signl2_decom.data_sample(:,1:signl2_decom.data_length*signl2_decom.sps);%%%%delete extra zeros
wave2.prop(signl2_decom);

signl2_decom.msg(1,:) = downsample(signl2_decom.data_sample(1,:),14);
signl2_decom.msg(2,:) = downsample(signl2_decom.data_sample(2,:),14);

x_data = qamdemod(signl2_decom.msg(1,:) ,4);
y_data = qamdemod(signl2_decom.msg(2,:) ,4);

x_tr_data = sig2.msg(1,:);
y_tr_data = sig2.msg(2,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%calc error raet#############################
err = 0;
for i = 1:length(x_data)
    
  if(x_data(i)~=x_tr_data(i))
     err=err+1; 
  end
  
end

err = err/length(x_data)

