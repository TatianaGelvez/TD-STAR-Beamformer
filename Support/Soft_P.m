function [BeamSgnlSoft] = Soft_P(BeamSgnlDAS,NMicro, na, nb,LongSgnl,NSampls,R,c,fe, n0, SgnlFlt,res)


tau_v        = [40.5 80.5 160.5]*1e-8;%[0.6 1.1 1.6 2.1 2.6 3 3.1]*1e-5;%[1e-6 3e-6 5e-6 6e-6 7e-6 8e-6 9e-6 11e-6 13e-6 15e-6]*1e2;
lambd_v      = [2.6e-1 3e-1 4e-1 14e-1]*1e-0;%[0.8e-0 0.9e-0 1.0e-0]*1e-0+0.2;%[1.2e-1 1.4e-1 1.6e-1 1.8e-1 2e-1 2.2e-1 2.4e-1]*1e-0;
errorSoftM   = zeros(length(tau_v),length(lambd_v));
minError     = Inf;
NIter        = 30;
%figure,
for cont_tau = 1:length(tau_v)
    tau          = tau_v(cont_tau);
    for cont_lambd = 1:length(lambd_v)
        lambd        = lambd_v(cont_lambd);
        BB5          = BeamSgnlDAS;   %%%Initialization
        for cont = NIter
            aux4        = DAS_P_Transpose(NMicro, na,nb, BB5, LongSgnl, R, c, fe, n0);
            aux2        = reshape(aux4(:)-SgnlFlt(:),NMicro,[]);
            aux3        = DAS_P(na,nb, NMicro, aux2, NSampls, R, c, fe, n0);
            aux         = BB5 - tau*(aux3);
            poss        = aux ~= 0;
            auxSign     = zeros(size(aux));
            auxSign(poss) = aux(poss)./abs(aux(poss));
            BB5           = (auxSign).*max(abs(aux) - lambd,0);
        end
        BB5Soft        = BB5;
        errorSoft      = norm(BB5Soft(:),1);
        fprintf("Error with L2-L1 Soft %2.4f \n",errorSoft)
        errorSoftM(cont_tau, cont_lambd) = errorSoft;
        if errorSoft < minError && errorSoft > 2500
            BeamSgnlSoft = BB5Soft;
            res.BB5      = BB5Soft;
            minError     = errorSoft;
            res.minError = minError;
            res.tau      = tau;
            res.lmbd     = lambd;
            res.BeamSgnlSoft = BeamSgnlSoft;
            save('res_L2L1_daFilteredSimulated8.mat','res')
        end
    end
end
end