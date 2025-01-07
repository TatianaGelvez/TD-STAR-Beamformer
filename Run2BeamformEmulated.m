%%%% Code for performing beamforming under reverberation conditions to
%%%% estimate the direction of arrival from an impulsive recorded signal
%%%% Author: Tatiana Gelvez-Barrera - October 2024
%%%% Code related to ICASSP Conference 2025 
%%%% Time-domain Beamforming for Room Acoustics Analysis
%%%% based on Reverberant Field Estimation 
clear variables; close all; clc

%%Parameters %% measurements June 05
addpath('Data/','Support/', 'Support/FrequencyMethods')  
load('Data/position_micros.mat')
load('Data/SimulatedRFSgnlPaper.mat')
name = "Beamfroming Simulated Data";

%%Position of the microphones
PosMicX       = x;
PosMicY       = y;
PosMicZ       = zeros(1, numel(PosMicY));
clear x; clear y;

%%Recorded signal
tt          = 4096;
res.ca      = 1;
res.cb      = round(res.ca+tt-1);

%%% Cropping the signal
Sgnl        = SgnlRF(:,res.ca:res.cb);

%%Filtering the signal
res.fa      = 2000;
res.fb      = 6000;
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
samplingFreq = samplingFreq*2;
res.fe       = samplingFreq;
SgnlFlt      = SgnlSmp;


%%Parameters
NSampls      = 1024;
speedOfSound = 340;
da           = 0.01;
alpha        = -1:da:1;
beta         = -1:da:1;
na           = length(alpha);
nb           = length(beta);
NMicro       = size(Sgnl,1);
res.da       = da;
res.NSampls  = NSampls;

%%%Calculate R
R       = zeros(na,nb,NMicro);
for aa=1:length(alpha)
    a = alpha(aa);
    for bb = 1:length(beta)
         b = beta(bb);
        if a^2+b^2<=1
        R(aa,bb,:)= -(PosMicX.*(a) + PosMicY.*(b));
        end
    end
end

ntaus     = round((R./speedOfSound).*samplingFreq);
LongSgnl  = NSampls + max(abs(ntaus(:))) + abs(min((ntaus(:))));
SgnlTime  = SgnlFlt(:,1:LongSgnl);
n0        = abs(min((ntaus(:))));

%%% Solution with TD-DAS
res.BeamSgnlDASt = DAS_P(na,nb, NMicro, SgnlTime, NSampls, R, speedOfSound, samplingFreq, n0);
res.BeamSgnlDAS  = sqrt(mean(res.BeamSgnlDASt.^2,3));
res.BeamSgnlDAS  = res.BeamSgnlDAS./max(res.BeamSgnlDAS(:));

%%% Solution with TD-RMV 
res.BeamSgnlMVt  = MV_P(na,nb, NMicro, SgnlTime, NSampls, R, speedOfSound, samplingFreq, n0, alpha, beta, PosMicX, PosMicY);
res.BeamSgnlMV   = sqrt(mean(res.BeamSgnlMVt.^2,3));
res.BeamSgnlMV   = res.BeamSgnlMV./max(res.BeamSgnlMV(:));


%%% Solution with proposed TD-STAR 
%res.BeamSgnlSoft = Soft_P(res.BeamSgnlDAS,NMicro, na, nb,LongSgnl,NSampls,R,speedOfSound,samplingFreq, n0, SgnlTime,res);

%%% Solution with FD-DAS FD-MV and FD-MUSIC
[result_DAS, result_MV, result_MUSIC, unique_i, unique_j,res] = FrequencyMethods(SgnlRF,res,samplingFreq, PosMicX,PosMicY,PosMicZ,speedOfSound);
res.BeamSgnlDASF    = result_DAS(1:1:end, 1:1:end);
res.BeamSgnlMVF     = result_MV(1:1:end,1:1:end);
res.BeamSgnlMUSICF  = result_MUSIC(1:1:end, 1:1:end);
res.idx    = unique_i(1:1:end);
res.idy    = unique_j(1:1:end);

figure, imagesc(alpha, beta,res.BeamSgnlDAS)
figure, imagesc(alpha, beta,res.BeamSgnlMV)
figure, imagesc(alpha, beta,result_MUSIC)
figure, imagesc(unique_i, unique_j,res.BeamSgnlDASF)
figure, imagesc(unique_i, unique_j,res.BeamSgnlMVF)
figure, imagesc(unique_i, unique_j,res.BeamSgnlMUSICF)


save('res_EmulatedData.mat','res')




