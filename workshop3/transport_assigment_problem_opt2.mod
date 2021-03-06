
param origenes;
param destinos;

set O:=1..origenes by 1;
set D:=1..destinos by 1;


param c{O,D} default 0;
param h{O,D} default 0;
param ct{o in O,d in D}:=  c[o,d] + h[o,d];
param s{O};
param de{D} default sum{o in O} s[o] - sum{d in D} de[d];

param M;


var x{O,D} >=0;

minimize fObj: sum{o in O, d in D} x[o,d] * ct[o,d];


s.t.  production{o in O}: sum{d in D}  x[o,d] =  s[o];
s.t.  supply{d in D}: sum{o in O}  x[o,d] =  de[d];

solve;

printf "\nFunción Objetivo: %f\n", fObj; 

display {o in O, d in D} x[o,d];
display {o in O,d in D} ct[o,d]; 


data;


param c: 1 2 3 4 5 6 7:=
	1 15 16 15 16 15 16 0
	2 18 20 18 20 18 20 0
	3 1000 1000 17 15 17 15 0
	4 1000 1000 20 18 20 18 0
	5 1000 1000 1000 1000 19 17 0
	6 1000 1000 1000 1000 22 22 0;

param h: 1 2 3 4 5 6  7:=
	1 0 0 1 2 2 3 0
	2 0 0 1 2 2 3 0
	3 1000 1000 0 0 2 1 0
	4 1000 1000 0 0 2 1 0
	5 1000 1000 1000 1000 0 0 0
	6 1000 1000 1000 1000 0 0 0;
	
param de:= 1 5 2 3 3 3 4 5 5 4 6 4 7 12;
param  s:= 1 10 2 3 3 8 4 2 5 10 6 3;
param  M:= 1000;

param origenes:= 6;
param destinos:=7;


end;
