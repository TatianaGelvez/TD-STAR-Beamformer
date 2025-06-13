function SgnlFlt = DAS_P_Transpose(NMicro, na,nb, BB, LongSgnl, R, c, fe, n0)
%%boucle formation de voies
Nsampls     = size(BB,3);
SgnlFlt     = zeros(NMicro,LongSgnl);
for im=1:NMicro %%loop for the sensors
    SgnlFltjj=zeros(1,LongSgnl);
    for ia=1:na %%loop for the positions
        for ib = 1:nb
            if(R(ia,ib,1)~= 0)
                tau           = R(ia,ib,:)./c;     %%Flying time
                ntau          = round(tau.*fe);  %%Calculate the number of the frequency
                SgnlFltjj(n0+ntau(:,:,im)+(1:Nsampls)) = SgnlFltjj(n0+ntau(:,:,im)+(1:Nsampls)) + permute(BB(ia, ib, :), [1,3,2]); %%Cumulative sum
            end
        end
    end
    SgnlFlt(im,:)    = SgnlFltjj;
end
end