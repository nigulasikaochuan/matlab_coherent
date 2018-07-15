% -------------------------------------------------------------------------
% LMS + PLL, from 2 samples per symbol to 1 sample per symbol
% By : Benoit Chatelain
% July 10 2009, McGill University

% v1
% -------------------------------------------------------------------------

function rxSymbolsOut = LMS_PLL(rxSignalIn, txSymbols, cnstl, varargin)

p = inputParser;
p.addParameter('verbose', false);
p.addParameter('display', false);
p.addParameter('TS', 1);
p.addParameter('filterInit', 2);
p.addParameter('nTaps', 13);
p.addParameter('LMSmuTS', 0.001);
p.addParameter('LMSmuDATA', 0.0001);
p.addParameter('PLLg', 0);
p.addParameter('nLoops', 2);
p.addParameter('M',4);
p.parse(varargin{:});
Opt = p.Results;

TS = Opt.TS;
filterInit = Opt.filterInit;
nTaps = Opt.nTaps;
LMSmuTS = Opt.LMSmuTS;
LMSmuDATA = Opt.LMSmuDATA;
g = Opt.PLLg;
nLoops = Opt.nLoops;

txSymbols = circshift(txSymbols.', ceil(-(nTaps+1)/4)).';

SignalX = rxSignalIn(1,:);
SignalY = rxSignalIn(2,:);

Training_Symbols_X = txSymbols(1, :);
Training_Symbols_Y = txSymbols(2, :);

TS_Block_Length = length(Training_Symbols_X);

PLL_Error_X = zeros(1, length(SignalX)/2);
PLL_Phase_X = PLL_Error_X;

PLL_Error_Y = zeros(1, length(SignalY)/2);
PLL_Phase_Y = PLL_Error_Y;

hxx = zeros(1,nTaps) + 1i*zeros(1,nTaps);
hyy = zeros(1,nTaps) + 1i*zeros(1,nTaps);
hxy = zeros(1,nTaps) + 1i*zeros(1,nTaps);
hyx = zeros(1,nTaps) + 1i*zeros(1,nTaps);

if filterInit == 1
    % Tap Initialization #1
    hxx((nTaps+1)/2) = 0;
    hyy((nTaps+1)/2) = 0;
    hxy((nTaps+1)/2) = 1;
    hyx((nTaps+1)/2) = 1;
    
elseif filterInit == 2
    % Tap Initialization #2
    hxx((nTaps+1)/2) = 1;
    hyy((nTaps+1)/2) = 1;
    hxy((nTaps+1)/2) =  0;
    hyx((nTaps+1)/2) = 0;
    
elseif filterInit == 3
    % Tap Initialization #3
    hxx((nTaps+1)/2) = 1;
    hyy((nTaps+1)/2) = 0;
    hxy((nTaps+1)/2) =  0;
    hyx((nTaps+1)/2) = 1;
    
elseif filterInit == 4
    % Tap Initialization #4
    hxx((nTaps+1)/2) = 0;
    hyy((nTaps+1)/2) = 1;
    hxy((nTaps+1)/2) =  1;
    hyx((nTaps+1)/2) = 0;
end

AllError  = zeros(length(SignalX)/2,1);
AllCoefs = zeros(length(SignalX)/2,nTaps,4);

SignalXOut = zeros(1,length(SignalX)/2);
SignalYOut = zeros(1,length(SignalX)/2);


for iLoop = 1:nLoops
    
    if iLoop == 2
        TS = 0;
    end
    
    for aa = nTaps+1:2:length(SignalX)	% Equalizer taps setting
                
        % Align input reference signal
        xx = SignalX(aa-nTaps:aa-1);
        yy = SignalY(aa-nTaps:aa-1);
         
        xx = fliplr(xx);
        yy = fliplr(yy);        
        
        % Compute output signal for each polarization
        xout_NoPLL = hxx * xx.' + hxy * yy.';
        yout_NoPLL = hyx * xx.' + hyy * yy.';
        
        xout = xout_NoPLL.*exp(-1j*PLL_Phase_X((aa-nTaps+1)/2));
        yout = yout_NoPLL.*exp(-1j*PLL_Phase_Y((aa-nTaps+1)/2));
        
        SignalXOut((aa-nTaps+1)/2) = xout;
        SignalYOut((aa-nTaps+1)/2) = yout;
        
        % Decision
        
        if TS == 1 && (aa-nTaps+1)/2 <= TS_Block_Length           
            
            mu = LMSmuTS;
            xout_CPR_Decision =  Training_Symbols_X((aa-nTaps+1)/2);
            yout_CPR_Decision =  Training_Symbols_Y((aa-nTaps+1)/2);
            
            
%             if TS == 1
%                 xout_CPR_Decision =  Training_Symbols_X((aa-nTaps+1)/2-TS_Block_Length);
%                 yout_CPR_Decision =  Training_Symbols_Y((aa-nTaps+1)/2-TS_Block_Length);
%             else
        else
            mu = LMSmuDATA;
            [~, xout_CPR_Decision] = Demapper(xout, cnstl);
            [~, yout_CPR_Decision] = Demapper(yout, cnstl);
%             xout_CPR_Decision = qamdemod(xout,Opt.M);
%             yout_CPR_Decision = qamdemod(yout,Opt.M);
        end
               
        %PLL
        PLL_Error_X((aa-nTaps+1)/2) = imag(xout.*conj(xout_CPR_Decision));
        PLL_Error_Y((aa-nTaps+1)/2) = imag(yout.*conj(yout_CPR_Decision));
        
        PLL_Phase_X((aa-nTaps+1)/2+1) = g*PLL_Error_X((aa-nTaps+1)/2)+PLL_Phase_X((aa-nTaps+1)/2);
        PLL_Phase_Y((aa-nTaps+1)/2+1) = g*PLL_Error_Y((aa-nTaps+1)/2)+PLL_Phase_Y((aa-nTaps+1)/2);
                
        % Compute error signal for each polarization
        Ex = xout_CPR_Decision-xout;
        Ey = yout_CPR_Decision-yout;
        
        % Update PMD filter coefficients (LMS algorithm)
        hxx = hxx + mu*Ex*conj(xx.*exp(-1j*PLL_Phase_X((aa-nTaps+1)/2)));
        hxy = hxy + mu*Ex*conj(yy.*exp(-1j*PLL_Phase_Y((aa-nTaps+1)/2)));
        hyx = hyx + mu*Ey*conj(xx.*exp(-1j*PLL_Phase_X((aa-nTaps+1)/2)));
        hyy = hyy + mu*Ey*conj(yy.*exp(-1j*PLL_Phase_Y((aa-nTaps+1)/2)));        
        
        AllError(aa/2,1) = abs(Ex)^2;
        AllError(aa/2,2) = abs(Ey)^2;
        
        AllCoefs(aa/2,:,1) =  hxx;
        AllCoefs(aa/2,:,2) =  hxy;
        AllCoefs(aa/2,:,3) =  hyy;
        AllCoefs(aa/2,:,4) =  hyx;
                        
    end
    
end

rxSymbolsOut(1,:) = SignalXOut;
rxSymbolsOut(2,:) = SignalYOut;


if (Opt.display)
    figure
    plot(AllError(:,1))
    title('Error Signal X')
    
    figure
    plot(AllError(:,2))
    title('Error Signal Y')
    
    figure
    plot(real(AllCoefs(:,8,1)),'r-');hold on;
    plot(real(AllCoefs(:,8,2)),'b-');
    plot(real(AllCoefs(:,8,3)),'k-');
    plot(real(AllCoefs(:,8,4)),'m-');
    legend('hxx','hxy','hyy','hyx');
    
    figure
    subplot(4,1,1)
    plot(real(AllCoefs(end-5000,:,1))), hold on
    plot(imag(AllCoefs(end-5000,:,1)),'r')
    title('hxx')
    subplot(4,1,2)
    plot(real(AllCoefs(end-5000,:,2))), hold on
    plot(imag(AllCoefs(end-5000,:,2)),'r')
    title('hyx')
    subplot(4,1,3)
    plot(real(AllCoefs(end-5000,:,3))), hold on
    plot(imag(AllCoefs(end-5000,:,3)),'r')
    title('hyy')
    subplot(4,1,4)
    plot(real(AllCoefs(end-5000,:,4))), hold on
    plot(imag(AllCoefs(end-5000,:,4)),'r')
    title('hxy')
    
    
    figure;
    plot(PLL_Phase_X);
    figure;
    plot(PLL_Phase_Y);
end


end
