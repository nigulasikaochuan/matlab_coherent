function plot_const(wavein)
    N = 4;
    Nbeside = 20;
    indexdata = zeros(length(wavein),N);
    angledata = linspace(0,pi/2,N);
    for m = 1:N
        data = real(exp(1j*angledata(m)))*real(wavein)+...
            imag(exp(1j*angledata(m)))*imag(wavein);
        [~,sortdata] = sort(data); 
        indexdata(:,m) = sortdata;
    end
    dis = zeros(length(indexdata),N);
    for kk = 1:N
        for k = 1:length(indexdata)
            indexbeg = k-Nbeside;
            if indexbeg < 1
                indexbeg = 1;
            end
            indexend = indexbeg+Nbeside*2+1;
            if indexend > length(data)
                indexend = length(data);
                indexbeg = length(data)-2*Nbeside;
            end  
            datatemp = wavein(indexdata(indexbeg:indexend,kk))-wavein(indexdata(k,kk));
            [t1,t2]=sort(abs(datatemp));
            dis(indexdata(k,kk),kk) = t1(2);
        end      
    end
    disdata = (min(dis,[],2));
    disdata = (disdata/max(abs(disdata))).^0.1;
    Nslice = 512;
    [conters1,centers1] = hist(disdata,Nslice);
    cpdf = zeros(1,Nslice);
    cpdf(1) = conters1(1);
    for k = 2:Nslice
        cpdf(k) = cpdf(k-1)+conters1(k);
    end
    cpdf = cpdf/cpdf(end);
    indexcolor = ceil(cpdf*Nslice);

    halfwide = (centers1(2)-centers1(1))/2;       
    factor = 0.5;
    istart = round(Nslice/factor*(1-factor)/2);
    cmap = jet(round(Nslice/factor));
    cmap = cmap(istart:istart+Nslice-1,:);
    cmap = flipud(cmap);

    figure;
    hold on
    for k = Nslice:-1:1
        plot(wavein((disdata>=centers1(k)-halfwide)&(disdata<=centers1(k)+halfwide)),...
            'linestyle','none','marker','.',...
            'MarkerFaceColor',cmap(indexcolor(k),:),'MarkerEdgeColor',cmap(indexcolor(k),:));
    end
    xlabel('In-Phase');
    ylabel('Quadrature');
    grid on
end