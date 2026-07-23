ts = 1e-9;
Fref = 10e6;
Tref = 1/Fref;
N = 16;
DCO_WL = 17;
dco_base = round(N*Fref*ts*2^DCO_WL);

