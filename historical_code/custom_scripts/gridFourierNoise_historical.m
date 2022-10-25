function [Fs, N, P1] = gridFourierNoise(didv, Vred)
%gridFourierNoise Plot Fourier transform of data
%   Fs = sampling rate (# samples/bias range)
%   N = # of sample (bias resolution)
%   P1 = spectral information

ftdata = zeros(size(didv));
for k = 1:size(didv,2)
    for l = 1:size(didv,3)
        ftdata(:,k,l) = fft(didv(:,k,l));
    end
end

N = size(didv,1); % number of samples (number of bias points)
Fs = N/range(Vred); % per bias for each sample (V)

coherentsum = sum(sum(ftdata,3),2);
P2 = abs(coherentsum/N); % get the double sided spectrum
P1 = P2(1:round(N/2)+1); % use only the positive frequencies
P1(2:end-1) = 2*P1(2:end-1); % normalise

f = Fs*(0:round(N/2))/N;
f = f/Fs*2;

figure;plot(f,P1)
xlabel('(1/V)')
title('Fourier transform spectra of dI/dV')

% xx = round(length(coherentsum)/20);
% xlim([xx length(coherentsum)-xx])

end

