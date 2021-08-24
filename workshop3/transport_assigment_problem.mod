# Problema transporte de asignacion

set A; # Articulos
set M; # Meses
set H; # Horario de prod.


param c{A,M,H}; # Costo de producir el articulo a en el mes m y en el horario h
param d{A,M};   # Demanda del articulo a en el mes m
param f{A,M};   # Costo de almacenamiento del articulo a en el mes m
param s{M,H};   # capacidad maxima en el horario h en el mes m

var x{A,M,H} >= 0; # Produccion del articulo a en el mes m en el horario h
var y{A,M} >= 0;   # Inventario del articulo a en el mes m


# minimizacion de costos de produccion y almacenamiento durante 3 meses
minimize fObj: sum{a in A , m in M, h in H} c[a,m,h] * x[a,m,h] + sum{a in A, m in M} y[a,m] * f[a,m]  ;


s.t. cumplimientoDemanda{a in A,m in M: m > 1}: sum{h in H} x[a,m,h] + y[a,m-1] >= d[a,m];
s.t. capacidadMaxima{m in M}: sum{a in A, h in H} x[a,m,h] <= sum{h in H} s[m, h];
s.t. inventarioPrimerMes{a in A, m in M: m = 1}: sum{h in H} x[a,m,h] - d[a,m] = y[a,m];
s.t. inventarioMes{a in A, m in M: m > 1}: sum{h in H} x[a,m,h] - d[a,m] + y[a, m-1] = y[a,m];


solve;

printf "\nFunción Objetivo: %f\n", fObj; 

display {a in A, m in M, h in H} x[a,m,h]; 
display {a in A, m in M} y[a,m];
display {a in A, m in M} d[a,m];
display {m in M, h in H} s[m,h];
display {a in A, m in M, h in H} x[a,m,h]*c[a,m,h]; 


data;
	set A:= articulo1 articulo2;
	set M:= 1 2 3;
	set H:= horarioN horarioE;

	param c:= 
	[articulo1,*,*]: horarioN horarioE:=
				1	 15      18
				2 	 17 	 20
				3 	 19 	 22
	[articulo2,*,*]: horarioN horarioE:=
				1	 16      20
				2 	 18 	 18 
				3 	 17 	 22;
	param d: 	     1    2    3:=
		articulo1 	 5    3    4
		articulo2    3    5    4;
	param f:       1     2    3:=
		articulo1  1     2    100
		articulo2  2     1    100;
	param s: horarioN horarioE:=
		1 	  10         3
		2      8         2
		3     10         3;
end;
