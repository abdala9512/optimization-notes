set C; # Coordenadas
set M; # Maquinas 

param coord{C,M}; # Coordenada c de la maquina m
param low{C}; # Valores inferiores x1 x2 cuadrado
param upp{C}; # Valores superiroes x1 x2 cuadrado

var x{C}; # Coordenada c  de la maquina nueva
var phi_{C, M}; # Distancia de la coordenada c de la maquina nueva a la coordenada c de la maquina m

minimize fObj: sum{c in C, m in M} phi_[c, m];

s.t. absoluteValueRestriction1{c in C, m in M}: phi_[c,m] >= x[c]-coord[c, m] ;
s.t. absoluteValueRestriction2{c in C, m in M}: phi_[c,m] >= -1*(x[c]-coord[c, m]) ;
s.t. zoneRestriction{c in C}: low[c] <= x[c] <= upp[c];


data;
	set M:= m1 m2 m3 m4;
	set C:= x1, x2;
	param coord:  m1  m2  m3  m4:=
			x1     3   0   -2  1
			x2     0  -3    1  4;
	param low:= x1 -1 x2 0;
	param upp:= x1 2 x2 1;
end;
