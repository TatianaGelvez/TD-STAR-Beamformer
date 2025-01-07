%%% Simulation of a source signal and its recording in a reverberant
%%% environment with a planar microphone array.
%%% Author: Tatiana Gelvez-Barrera - October 2024
%%% Code related to ICASSP Conference 2025 
%%% Time-domain Beamforming for Room Acoustics Analysis
%%% based on Reverberant Field Estimation 

clear variables; close all; clc;
addpath("Support/", "Figures/", "Data/", "Results/");

% Load microphone positions
load('Data\position_micros.mat'); % File contains variables `x` and `y`

%%% Simulation Parameters
roomDimensions  = [11.5, 4.3, 8.5]; % [Lx, Ly, Lz] in meters
reflectionCoeff = 0.90;             % Reflection coefficient of the walls
speedOfSound    = 340;              % Speed of sound in air (m/s)
sourcePosition  = [5.7,1.23,4.37];  % Source coordinates (x, y, z) Others: [6.5, 2.5, 0]
receiverCenter  = [5.7, 2.0, 0];    % Central receiver position (x, y, z)
samplingFreq    = 51200;            % Sampling frequency (Hz)
recordingTime   = 0.080;            % Recording duration (seconds)
timeVector      = 0:1/samplingFreq:recordingTime; % Time vector
backgroundNoise = 0.01 * randn(size(timeVector)); % Background white noise

%%% Impulse signal parameters
impulseFreq       = 4000;           % Frequency of the impulse (Hz)
impulseDuration   = 0.0003;         % Impulse duration (seconds)
impulseEmission   = 0.0131;         % Impulse emission time (seconds)
SNR               = 10;             % Acquisition Noise in Signal-to-Noise Ratio (dB)

%%% Generate the Source Signal
impulseStartSample = round(impulseEmission * samplingFreq);      % Sample where impulse starts
impulseNumSamples  = round(impulseDuration * samplingFreq);      % Number of samples for the impulse
impulseTime        = (0:impulseNumSamples-1) / samplingFreq;     % Time vector for the impulse
impulseAmplitude   = linspace(2, 1.5, length(impulseTime));      % Linearly decreasing amplitude
sinusoidalImpulse  = impulseAmplitude .* sin(2 * pi * impulseFreq * impulseTime);
impulseSignal      = zeros(size(timeVector)); % Initialize with zeros
impulseSignal(impulseStartSample:impulseStartSample+impulseNumSamples-1) = sinusoidalImpulse;
sourceSignal       = backgroundNoise + impulseSignal;
sourceSignal       = sourceSignal./max(abs(sourceSignal)); % Normalize the source signal

%%% Emulate RF Signal
numMicrophones  = size(x, 1); % Number of microphones
RFSgnl = zeros(numMicrophones, length(sourceSignal)); % Initialize array for received signals
for micIdx = 1:numMicrophones
    micPosition = [x(micIdx), y(micIdx), 0] + receiverCenter;
    [imageSources, orders, micSignal, impulseResponse] = reverb(...
        sourceSignal, samplingFreq, ...
        roomDimensions(1), roomDimensions(2), roomDimensions(3), ...
        sourcePosition, micPosition, reflectionCoeff, speedOfSound); 
    % Add noise to the signal based on the SNR
    signalPower  = mean(micSignal.^2);
    snrLinear    = 10^(SNR / 10); % Convert SNR from dB to linear scale
    noisePower   = signalPower / snrLinear;
    noise        = sqrt(noisePower) * randn(1, length(sourceSignal));
    RFSgnl(micIdx, :) = micSignal(1:length(sourceSignal)) + noise;
end

%% Save Results
save("Data/SimulatedRFSgnl.mat", "RFSgnl", "sourceSignal", ...
    "timeVector", "roomDimensions", "sourcePosition", "receiverCenter", "imageSources", "orders", "samplingFreq");


%%%Visualization
%figure, plot(timeVector,sourceSignal); title('Impulsive Sound'); xlabel("time [s]"); ylabel("Amplitude");
%figure, plot(impulseResponse); title('Impulse response'); ylabel('Amplitude');
plotRFSgnl(RFSgnl, timeVector);
plotRoom(roomDimensions,imageSources',receiverCenter);

