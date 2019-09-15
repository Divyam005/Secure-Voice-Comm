function f = pitchdetect(X, thresh)

%X = windowing(x, fs);

[n,~] = size(X);
f = [];
for i = 1:n
    [autocorr,lags] = xcorr(X(i,:));
    ind = find(lags == 0);
    autocorr = autocorr(ind:end);
    autocorr = autocorr/autocorr(1);
    [pks, locs] = findpeaks(autocorr);
    %[mm,peak1_ind]=max(pks);
    [vals,order] = sort(pks,'descend');
    locs = locs(order);
    
     if(~(isempty(vals)))
         if(vals(1) < thresh)
             period = 0;
         else
%             loc = loc(order);
%             pitch = loc(1);
        period=locs(1); 
         end
     else
         period = 0;
     end
     f = [f;period];

end
end
