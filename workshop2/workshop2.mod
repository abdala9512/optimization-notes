/*
Taller #2
MIGUEL ARQUEZ ABDALA
*/

# Conjuntos
param jJuguetes;
set J:= 1..jJuguetes by 1;
set P;


# Parametros
param c{J};
param g{J};
param t{J,P};
param d{P};
param M{j in J, p in P} default  d[p] / t[j,p];

# variables
var x{J,P} >= 0; 
var y{P}, binary; # 1 si se usa la platan, 0 en otro caso
var w{J}, binary;

# Funcion obj. y restricciones

maximize fObj: sum{j in J, p in P} g[j]*x[j,p] - sum{j in J} w[j]*c[j];

s.t. disponibilidadHoras{p in P}: sum{j in J} t[j,p] * x[j,p] <= d[p] * y[p];
s.t. usoUnaPlanta: sum{p in P} y[p] <= 1;
s.t. restriccionProd{j in J, p in P}: M[j,p] * w[j] >= x[j, p];

solve;

printf "\nFunción Objetivo: %f\n", fObj; 
display {j in J, p in P} x[j, p]; 


# datos
data;

set P:= planta1 planta2;

param c:= 1 50000 2 80000;
param g:= 1 10 2 15;
param t: planta1 planta2:=
		1 0.02 0.025 
		2 0.025 0.04;
param d:= planta1 500 planta2 700;
param jJuguetes:= 2;

end;
