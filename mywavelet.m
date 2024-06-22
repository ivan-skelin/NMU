




function [wFreq,tfdata] = mywavelet(data,Fs,n_wavelets,wFreq)
wTime= -1:(1/Fs):1;
wLength= length(wTime);

n=n_wavelets;
s=n./(2*pi*wFreq);
A=1./sqrt(s*sqrt(pi));

tfdata = zeros(length(wFreq),length(data));

for nn= 1 : length(wFreq)
    morl_wavelet = A(nn)*exp((-wTime.^2)/(2*s(nn)^2)).*exp(i*2*pi*wFreq(nn)*wTime);
    tfdata (nn,: )= conv(data,morl_wavelet,'same');
end

    

