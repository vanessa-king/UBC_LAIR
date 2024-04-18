% To use this function, download Signal Processing toolbox 
function [smoothed_vector] = gaussfilter1d(vector, sigma)
    N = 6*sigma + 1; % Create Gaussian window wide enough to encapsulate the std. dev.
    
    alpha = 3; % alpha = (N-1)/(2*sigma) = 3
    g = gausswin(N,alpha); % Gaussian window generating function
    g = g/sum(g); % Normalize the Gaussian window to sum to 1
    
    smoothed_vector = filtfilt(g,1,vector); % Zero-phase filter to smooth data
end