clc;
clear all;

sps = 4;
sig1 = Signal(35e9,4,"dp-qpsk",2^16,true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%pulse_shape%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param.roll_off=0.2;
param.sps=sps;
param.span = 6;

wav = Wave(param);
fvtool(wav.h,'analysis','impulse');
wav.prop(sig1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%add noise%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ebn0 = 10;
snr = ebn0 + 10*log10(2) - 10*log10(sps);
sig1.data_sample(1,:)= awgn(sig1.data_sample(1,:),snr,'measured');

sig1.data_sample(2,:)= awgn(sig1.data_sample(2,:),snr,'measured');
% scatterplot(sig1.data_sample(1,:));
% scatterplot(sig1.data_sample(2,:));
% eyediagram(sig1.data_sample(2,2:1000),2*sps);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%match_filter%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wav.prop(sig1);
scatterplot(sig1.data_sample(1,:));
eyediagram(sig1.data_sample(2,2:1000),2*sps);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%cma equa%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cma_alg = cma(0.01);
% eq1 = lineareq(11,cma_alg);
% eq1.SigConst = sig1.costl;
% eq1.nSampPerSym = sps;
% eq1.Weights(6)=1;
% data_eqsample(1,:)=equalize(eq1,sig1.data_sample(1,:));
% data_eqsample(2,:)=equalize(eq1,sig1.data_sample(2,:));
% scatterplot(data_eqsample(1,:));
% eyediagram(data_eqsample(2,2:1000),2*sps);
% lms_alg = lms(0.001);
% eq1 = lineareq(11,lms_alg);
% eq1.SigConst = sig1.costl;
% eq1.nSampPerSym=sps;
% data_eqsample(1,:)=equalize(eq1,sig1.data_sample(1,:),sig1.data(1,:));
% data_eqsample(2,:)=equalize(eq1,sig1.data_sample(2,:),sig1.data(2,:));
% scatterplot(data_eqsample(1,:));
% eyediagram(data_eqsample(2,2:1000),2*sps);

% eq.ros = sps;
% eq.Ntrain = 1024;
% eq.mu=0.01;
% eq.M = 4;
% eq.Ntaps=11;
% eq.trainSeq = length(sig1.data);
% eq.structure = '4 filters';
% [y,~,~] = lms_td_fse(sig1.data_sample,eq,true);

sigIn = [downsample(sig1.data_sample(1,:),2);downsample(sig1.data_sample(2,:),2)];


data_eqsample = LMS_PLL(sigIn,sig1.data,sig1.costl,'display',true);
%%%%%%%%%%%%%demod%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [acor,lag] = xcorr(data_eqsample(1,:),sig1.data(1,:));
% [~,index] = max(abs(acor));
% symdelay = lag(index);
data_eqsample(1,:) = Synchronization(data_eqsample(1,:),sig1.data(1,:),'nSamplePerSymbols',1);
data_eqsample(2,:) = Synchronization(data_eqsample(2,:),sig1.data(2,:),'nSamplePerSymbols',1);


data1= data_eqsample(1,:);
% data1 = downsample(sig1.data_sample(1,:),4);
data1 = qamdemod(data1,4);

data2 = sig1.msg(1,:);
err=0;
for i=1:length(data2)
   if data2(i)~=data1(i)
      err=err+1; 
   end
end
err/length(data2)
