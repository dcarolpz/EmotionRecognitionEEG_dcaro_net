function [e,ref] = dcaro_DWT_ANC_test(x,wavelet,level)
    arguments
        x double
        wavelet char = 'db4'
        level double {mustBeInteger} = 7
    end

    [c,l] = wavedec(x,level,wavelet);
    D = detcoef(c,l,1:7);
    AN = appcoef(c,l,wavelet,level);

    T = zeros(1,level);
    D2 = D;
    for i = 1:level
        sj = median(abs(D{i}-median(D{i})))/0.6745; 
        T(i) = sj*sqrt(2*log(length(c)));
        if i < 4 
            D2{i} = wthresh(D{i},'s',T(i));
        else
            continue
        end
    end
    
    c2 = [AN flip(cell2mat(cellfun(@flip,D2,'UniformOutput',false)))];
    ref = waverec(c2,l,wavelet);

    e = zeros(size(x));
    % Pi = zeros(1,size(ref,2));
    P = 1e4;
    lambda = 0.98;
    w = 1;
    for k = 1:size(ref,2)
        Pi = ref(k)*P;
        
        g = Pi/(lambda + Pi.*P);
        y = w*ref(k);
        
        e(k) = x(k) - y;
        
        w = w + g*e(k);
        P = (P - g*Pi)/lambda;
    end
end
