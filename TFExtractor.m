% @title        Transfer-Function Extractor
% @file         TFExttractor.m
% @short        An simple FFT based transfer function extractor
% @version      0.1
% @date         27. September 2021
% @copyright    All rights reserved by Christoph Lauer
% @author       Christoph Lauer
% @contributors none
% @client       company
% @language     MATLAB R2021a (Octave) 
% @packages     none
% @param        none
% @return       none
% @notes        see the papers in the doc section
% Toolbox       none
% @todo         
% @copyright    Christoph Lauer
% @license      GPL 3.0
% @brief        This matlab file implements an FFT-IFFT based
%               transfer-function method.
% @contact      christophlauer@me.com
% @webpage      https://christoph-lauer.github.io

%% 0.) 
clear;

%% 1.) GENERATE THE EXPONENTIAL SINUS SWEEP
sr = 48000;                                     % the sample rate
dur = 3;                                        % the signal duration
excitation = sweeptone(dur,1,sr);               % the exponential sweep signal with 1 second silence at the end

%% 2.) PLAY AND RECORD THE SWEEP
sound(excitation,sr);                           % play the exponential sine sweep signal
recObj = audiorecorder(sr,16,1);                % create the auid recorder 
recordblocking(recObj, 4);                      % recorde 4 seconds
recording = getaudiodata(recObj);               % ret the recording raw data
play(recObj);                                   % re-play the recording

%% 3.) PLOT THE SPECTOGRAM
plot(recording);                                % plot the recording
spectrogram(recording,1024);                    % plot the spectogram

%% 4.) SHIFT THE SIGNALS IN PLACE
%% 4.1) DETERMINE SHIFT
cor = xcorr(excitation, recording);             % crosss correlation
plot(cor);                                      % plot the cros correlation
[peakVal, peakPos] = max(abs(cor));             % search the peak position
shift = peakPos - floor(length(cor)/2);
%% 4.2) APPLY SHIFT
excitation = cat(1, excitation, zeros(shift,1));% zero padding
recording = cat(1, zeros(shift,1), recording);  % zero padding
plot(recording);                                % plot the zero padded recording

%% 5.) THE TRANSFER FUNCTION
%% 5.1) CALCULATE THE TRANSFER FUNCTION
excitation_F = fft(excitation);                 % fft
recording_F  = fft(recording);                  % fft
tf = recording_F ./ excitation_F;               % transfer function
tf = smooth(tf,200, 'lowess');                  % smooth the result
l = length(tf);                                 % length 
%% 5.1) PLOT THE TRANSFER FUNCTION
plot(abs(tf(ceil(l/2):l)),'LineWidth',2);       % plot transfer function
set(gca, 'YScale', 'log');                      % log y scale
set(gca, 'XScale', 'log');                      % log x scale
%set(gca,'Color','k');                          % black background
grid                                            % enable the grid
grid(gca,'minor');                              % and the minor thicks
xlabel('Frequency [Hz]');                       % x axis label
ylabel('Magnitude [db]');                       % y axis label
xt = get(gca, 'XTick');                         % get x ticks
set(gca,'XTick',xt/l*(sr*2)*10,'XTickLabel',xt);% print the rescaled x axis
title('Transfer Function H(f)');                % add the title

%% 6.0 IMPULSE RESPONSE
ir = ifft(tf);                                  % impulse response (abs or real?)
% TBD TBD TBD TBD TBD TBD TBD TBD T
% BD TBD TBD TBD TBD TBD TBD TBD TB
% D TBD TBD TBD TBD TBD TBD TBD TBD