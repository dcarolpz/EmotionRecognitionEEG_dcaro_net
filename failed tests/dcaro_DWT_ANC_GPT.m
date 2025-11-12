function varargout = dcaro_DWT_ANC_GPT(x,wavelet,level)
    arguments
        x double {}
        wavelet char = 'db4'
        level double {mustBeInteger} = 7
    end

    % Wavelet decomposition
    [c, l] = wavedec(x,level,wavelet);
    D = detcoef(c,l,1:level);
    A7 = appcoef(c,l,wavelet,level);

    % Thresholding (soft, first 3 levels)
    D2 = D;
    for i = 5:7
        sj = median(abs(D{i} - median(D{i})))/0.6745;
        T = sj*sqrt(2*log(length(D{i})));
        D2{i} = wthresh(D{i},'s',T);
    end

    % Rebuild coefficient vector correctly
    c2 = [A7 flip(cell2mat(cellfun(@flip,D2,'UniformOutput',false)))];

    % Reference reconstruction
    ref = waverec(c2,l,wavelet);

    % RLS (order M=1)
    P = 1e4;
    lambda = 0.98;
    w = 0;
    e = zeros(size(x));

    for k = 1:length(ref)
        g = (P * ref(k)) / (lambda + ref(k)^2 * P);
        y = w * ref(k);
        e(k) = x(k) - y;
        w = w + g * e(k);
        P = (P - g * ref(k) * P) / lambda;
    end

    varargout{1} = e;
    varargout{2} = ref;
end
