function [possi, ordrei, trackout, impulse] = reverb(sourceSignal, samplingFreq, Lx, Ly, Lz, SourceCoord, micPosition, reflectionCoeff, c)
    % Input:
    %   sourceSignal - Input sound track
    %   samplingFreq - Sampling frequency
    %   Lx, Ly, Lz   - Room dimensions (length, height, width)
    %   SourceCoord  - Source coordinates
    %   micPosition  - Position of microphone
    %   reflectionCoeff - Reflection coefficient
    %   c            - Speed of sound
    %
    % Output:
    %   possi        - Valid positions of image sources
    %   ordrei       - Order of reflections for the valid sources
    %   trackout     - Reverberated audio track
    %   impulse      - Room impulse response

    %%% Parameters
    maxOrder        = 4;       % Maximum reflection order
    threshold       = 0.001;   % Minimum amplitude threshold
    minGap          = 100;     % Minimum sample gap for significant reflections
    diffThreshold   = 0.01;    % Threshold for significant differences in impulse response

    %%% Step 1: Compute image sources and their orders
    [allSources, allOrders] = sourcesimages(Lx, Ly, Lz, SourceCoord, maxOrder);
    
    % Filter sources with order <= 3
    validIndices = find(allOrders <= 3);
    possi        = allSources(validIndices, :);
    ordrei       = allOrders(validIndices);

    %%% Step 2: Calculate distances from receiver to sources
    numSources   = size(possi, 1);
    distances    = sqrt(sum((repmat(micPosition, numSources, 1) - possi).^2, 2));
    
    % Sort sources by distance
    [distances, sortIdx] = sort(distances, "ascend");
    possi        = possi(sortIdx, :);
    ordrei       = ordrei(sortIdx);

    %%% Step 3: Filter sources based on threshold
    validSources = find((reflectionCoeff.^ordrei) ./ distances > threshold);
    possi        = possi(validSources, :);
    ordrei       = ordrei(validSources);
    distances    = distances(validSources);

    %%% Step 4: Compute impulse response
    delaySamples = round((distances ./ c) * samplingFreq); % Time delay in samples
    maxDelay     = ceil(max(delaySamples));
    impulse      = zeros(1, maxDelay); % Initialize impulse response
    impulse(delaySamples) = (1 ./ distances) .* (reflectionCoeff.^ordrei); % Impulse values

    %%% Step 5: Find significant differences in impulse response
    impulseDiff = impulse - circshift(impulse, -1);
    significantPositions = find(impulseDiff > diffThreshold);

    % Find positions with a minimum gap
    gaps = significantPositions - circshift(significantPositions, 1);
    largeGapIndices = find(gaps >= minGap);
    significantPositions = significantPositions([1 largeGapIndices]); % Include first position

    %%% Step 6: Apply the room impulse response to the input track
    % Use only the first few significant reflections for convolution
    impulseTruncated = impulse(1:significantPositions(5));
    trackout = conv(sourceSignal, impulseTruncated, "same");

    [ordrei, sortIdx] = sort(ordrei, "ascend");
    possi             = possi(sortIdx, :);
    distances         = distances(sortIdx, :);

end
