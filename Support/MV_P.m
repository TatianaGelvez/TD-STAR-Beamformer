function [BeamSgnl] = MV_P(na, nb, NMicro, SgnlFlt, NSampls, R, c, fe, n0, alpha, beta, PosMicX, PosMicY)
% Estimate covariance matrix
CM       = (1/size(SgnlFlt,2)) * (SgnlFlt * SgnlFlt');
delta    = 2e-3;
CMi      = (CM + delta*eye(size(CM)))^(-1);
BeamSgnl = zeros(na,nb,NSampls);

for ia=1:na %%loop for the alphas
    for ib = 1:nb
        if(R(ia,ib,1)~=0)
            tau     = R(ia,ib,:)./c;     %%Flying time
            ntau    = round(tau.*fe);    %%Calculate the number of the frequency
            Bjj     = zeros(1,NSampls);

            % MVDR beamforming weights
            steeringVector = exp(-1*2*pi/c * (alpha(ia)*PosMicX + beta(ib)*PosMicY));
            steeringVector = (steeringVector./norm(steeringVector));
            mvdrWeights    = (CMi * steeringVector)./ ((steeringVector' * CMi) * steeringVector);

            for jj=1:NMicro %%loop for the microphones
                BB_aux = SgnlFlt(jj, n0+ntau(1,1,jj)+(1:NSampls));
                Bjj    = Bjj+ (mvdrWeights(jj)).*BB_aux; %%Cumulative sum
            end
            BeamSgnl(ia,ib,:)=permute(Bjj, [1,3,2]);
        end
    end
end
end