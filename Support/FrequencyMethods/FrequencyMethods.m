function [result_DAS, result_MV, result_MUSIC, unique_i, unique_j,res] = FrequencyMethods(SgnlRF,res,samplingFreq, PosMicX,PosMicY,PosMicZ,speedOfSound)

%%% Computations for Frequency domain methods
samplingFreq         =  samplingFreq /2; %Restore to original sampling frequency
thetaScanningAngles  =  0:0.5:90;
phiScanningAngles    = -180:0.5:180;
CentralFrequency     = 4e3;
w                    = ones(1, numel(PosMicX))/numel(PosMicX);

%%Recorded signal (Use a longer siganl for FD methods)
tt          = 4096;
res.caf     = 1;
res.cbf     = round(res.caf+tt-1);

%%% Cropping the signal
Sgnl        = SgnlRF(:,res.caf:res.cbf);

%%Filtering the signal
SgnlFlt     = zeros(size(Sgnl));
[bb,aa]     = butter(3,[res.fa res.fb]/samplingFreq*2,'bandpass');
for ii=1:size(Sgnl,1)
   SgnlFlt(ii,:) = filtfilt(bb,aa,double(Sgnl(ii,:)));
end

%%Resampling the signal
SgnlSmp     = zeros(size(SgnlFlt,1),2*size(SgnlFlt,2));
for ii=1:size(SgnlSmp,1)
    SgnlSmp(ii,:) = resample(double(SgnlFlt(ii,:)),2,1);
end
samplingFreq  = samplingFreq*2;
SgnlFreq      = SgnlSmp;

%%Calculate steered response
e = steeringVector(PosMicX, PosMicY, PosMicZ, CentralFrequency, speedOfSound, thetaScanningAngles, phiScanningAngles);
R = CSM(SgnlFreq,CentralFrequency, samplingFreq, 128, 64);

S_DAS            = steeredResponseDelayAndSum(R, e, w);
S_DAS            = sqrt(abs(S_DAS.^2));
S_DAS            = S_DAS./max(S_DAS(:));
S_MV             = steeredResponseMinimumVariance(R, e);
S_MV             = sqrt(abs(S_MV.^2));
S_MV             = S_MV./max(S_MV(:));
[S_MUSIC, V, Vn] = steeredResponseMusic(R, e, 5);
S_MUSIC          = sqrt(abs(S_MUSIC.^2));
S_MUSIC          = S_MUSIC./max(S_MUSIC(:));

%%Calculate the equivalent ortographic angles
ntheta = length(thetaScanningAngles);
nphi   = length(phiScanningAngles);
val    = zeros(ntheta*nphi, 5);
contf  = 1;
for cont_a = 1:ntheta
    for cont_b = 1:nphi
        ele         = (thetaScanningAngles(cont_a))*pi/180;
        az          = phiScanningAngles(cont_b)*pi/180;
        my_al       = cos(az)*sin(ele);
        my_be       = sin(az)*sin(ele);
        val(contf,:) = [my_al my_be S_DAS(cont_a, cont_b) S_MV(cont_a, cont_b) S_MUSIC(cont_a, cont_b)];
        contf = contf + 1;
    end
end

[~, pos]     = sort(val(:,1), "ascend");
val          = val(pos,:);
val(:,1:2)   = round(val(:,1:2),2);

%%Obtener las parejas unicas (i, j) que corresponde a los angulos
%%ortograficos
[unique_pairs, ~, idx] = unique(val(:, 1:2), 'rows',"stable");
new_matrix             = zeros(size(unique_pairs, 1), 5);
for k = 1:size(unique_pairs, 1)
    matching_rows = (idx == k);
    avg_value3 = mean(val(matching_rows, 3));
    avg_value4 = mean(val(matching_rows, 4));
    avg_value5 = mean(val(matching_rows, 5));
    new_matrix(k, :) = [unique_pairs(k, :) avg_value3 avg_value4 avg_value5];
end
clear val;

%%Formar la nueva matriz en la representacion ortografica
unique_i     = unique(new_matrix(:, 1));
unique_j     = unique(new_matrix(:, 2));
result_DAS   = zeros(length(unique_i), length(unique_j));
result_MV    = zeros(length(unique_i), length(unique_j));
result_MUSIC = zeros(length(unique_i), length(unique_j));
for k = 1:size(new_matrix, 1)
    % Encontrar el índice correspondiente de i y j en las matrices únicas
    if( ((new_matrix(k, 1))^2 + (new_matrix(k, 2))^2 )<=1)
        i_index = find(unique_i == new_matrix(k, 1));
        j_index = find(unique_j == new_matrix(k, 2));
        result_DAS(i_index, j_index)   = new_matrix(k, 3);
        result_MV(i_index, j_index)    = new_matrix(k, 4);
        result_MUSIC(i_index, j_index) = new_matrix(k, 5);
    end
end
end