function [BeamSgnl] = DAS_P(na, nb, NMicro, SgnlFlt, NSampls, R, c, fe, n0)
BeamSgnl = zeros(na,nb,NSampls);
for ia=1:na %%loop for the alphas
    for ib = 1:nb
        if(R(ia,ib,1)~=0)
            tau     = R(ia,ib,:)./c;     %%Flying time
            ntau    = round(tau.*fe);    %%Calculate the number of the frequency
            Bjj=zeros(1,NSampls);
            for jj=1:NMicro %%loop for the microphones
                Bjj     = Bjj+ SgnlFlt(jj, n0+ntau(1,1,jj)+(1:NSampls)); %%Cumulative sum
            end
            BeamSgnl(ia,ib,:)=permute(Bjj, [1,3,2]);
        end
    end
end
end