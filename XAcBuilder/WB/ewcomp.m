function [gengewei, gnacewei, gpylnwei, gpropwei] = ewcomp(gmaxistc, gthrtrev, gengeloc, ginsttyp, id, z)

kthrr = 1+0.18*gthrtrev(id,z)/100;% factor to increase weight due to thrust rev.
gpropwei = 6.13*qxheavy(ginsttyp(id,z),1,1)*gmaxistc(id,z);% propeller
gengewei = 0.0117*(1+0.2*qxheavy(ginsttyp(id,z),1,1))*(gmaxistc(id, z)*1000)^1.0572;% dry engine weight
gnacewei = 0.345*(1+qxheavy(gengeloc(id,z),4,1))*(1-0.53*qxheavy(ginsttyp(id, z),1,1))*kthrr*gengewei;% nacelle weight
gpylnwei = 0.574*(1-qxheavy(gengeloc(id,z),4,1))*(1-qxheavy(ginsttyp(id, z),1,1))*gengewei^0.736;% pylon weight
