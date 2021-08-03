/*Ejercicio #3
MIGUEL ARQUEZ ABDALA

Problema:

Una compañía cuenta con varios vehículos, cada uno de los cuales cuenta con k compartimientos. Cada compartimiento está diseñado con capacidad limitada en cuanto a volumen y peso que puede transportar. Se desea transportar varios tipos de carga, de las cuales se conoce su densidad volumétrica(Kg/m3), la cantidad a transportar(Kg), la ganancia obtenida por cada unidad transportada($/Kg), un costo($)de transportar cada carga en cada vehículo (se cobra lo mismo independiente de la cantidad transportada). Para efectos del transporte, las cargas pueden fraccionarse y mezclarse entre ellas; sin embargo existen restricciones que impiden que algunas cargas puedan llevarse en el mismo compartimiento, y si se cargan en el mismo vehículo es obligatorio pagar un seguro ($) por esta práctica (El Monto de la póliza del seguro por transportar cada par de cargas i y j en el mismo vehículo es fijo, no depende de las cantidades transportadas).Inclusive, existen restricciones que impiden el transporte de algunas cargas en el mismo vehículo. Para efectos de que el vehículo no presente problemas en su funcionamiento, los compartimientos deben utilizar la misma razón peso transportado/capacidad de transporte de peso. Adicionalmente la compañía tiene categorizado sus vehículos(un vehículo puede pertenecer a varias categorías), y ha establecido que por cada categoría sólo un número máximo de vehículos pueden estar transportando carga. Finalmente, se debe cumplir que: si los vehículos 7 y 5 prestan el servicio, y el servicio 10 no lo presta, entonces el vehículo 1 debe prestar el servicio No puede prestarlo. El objetivo es determinar el plan de transporte para maximizar la ganancia para la compañía al transportar las cargas 

*/

# Conjuntos

set V; # vehiculos
set C; # Compartimientos
set S; # Catergoria de vehiculo
set F; # Cargas

# Parametros

param vol{V,C};  # Capacidad volumetrica del compartimiento c en el vehiculo v
param pes{V,C};  # Capacidad de carga del compartimiento c en el vehiculo v  (Kg)
param den{F};    # Densidad (Kg/m3) de la carga f
param oferta{F}; # Cantidad (Kg) de carga f disponible para transportar
param gan{F};      # Ganancia ($/Kg) por unidad transportada de la carga f

param restc{f in F, g in F};  # 1 si carga F no puede transportarse en el mismo compartimiento que la carga g. 0 En otro caso
param seguro{f in F, g in F};              #  valor_seguro(f,g)  si se debe pagar seguro por el transporte de cargar f y g en el mismo vehiculo
param valor_seguro{f in F, g in F};        # Valor del seguro a pagar si se transportarn las cargas f y g en el mismo vehiculo
param ban{f in F, g in F};            # 1 Si esta prohibido transportar cargas f y g en el mismo vehiculo
param cat_veh{V,S};      # 1 Si el vehiculo v corresponde a la categoria s
param max_use{S};        # Numero maximo de categoria s que puede ser usados para transporte
param cfc{F,V};          # Costo fijo de transportar la carga f en el vehiculo v (Independientemente de la cantidad transportada)


# Variables


var x{F, C, V} >= 0;             # Cantidad de la carga f en el compartimiento c en el vehiculo v
var y{F,C,V}, binary;            # 1. Si la carga f es transportafa en el vehiculo v en el compartimiento c. 0 en otro caso
var w{f in F,g in F, v in V}, binary;              # 1. si se transporta carga f y carga g en el vehiculo v. 0 En otro caso
var phi{V}, binary;              # 1. si el vehiculo v se usa para transportar carga. 0 En otro caso
var delta{F,V}, binary;          # 1 si carga f se transporta en el vehiculo v. 0 En caso contrario




# Funcion objetivo

maximize fObj:  sum{f in F, c in C, v in V} x[f,c,v] * gan[f] 
				- sum{f in F, v in V} delta[f,v] * cfc[f, v] 
				- sum{v in V, f in F,  g in F} seguro[f,g] * w[f,g,v] * valor_seguro[f,g];


# Restricciones

s.t. maxOferta{f in F}: sum{v in V, c in C} x[f,c,v] <= oferta[f]; # La suma de las cargas f en los compartimiento c en los vehiculos v no puede ser amyor a la oferta total de F
s.t. volMax{v in V, c in C}: sum{f in F} x[f,c,v] * 1 / den[f]   <= vol[v,c];
s.t. pesMax{v in V, c in C}: sum{f in F} x[f,c,v] <= pes[v,c];

s.t. cargaEsTransportada{f in F, c in C, v in V}: y[f,c,v] <= x[f,c,v];

#s.t.
s.t. mismoVehiculo{f in F, g in F, v in V}: delta[f,v] + delta[g,v] <= 1 + (1 - ban[f,g]); # Carga f no puede transportarse en el mismo vehiculo que la carga g
s.t. mismoCompartimiento{f in F, g in F, c in C, v in V}: y[f,c, v] + y[g,c,v] <= 1 + (1 - restc[f,g]); # Carga f no puede transportarse en el mismo compartimiento que la carga g
s.t. ambasCargasVehiculo{f in F, g in F,v in V}: delta[f,v] + delta[g,v] <= 1 + w[f,g,v]; # Cargas f y g puede tomar valores de 1 si solo una de las carga esta en el vehiculo v y 2 si ambas cargas estan en el vehiculo v. 2 es el max valor de esta restriccion

s.t. ponerNombre{v in V}: phi[v] <= sum{f in F} delta[f,v]; #  0 o 1 es menor que la suma de todas las cargas f que lleva el vehiculo V 
s.t.  usoMaxCategoria{s in S}: sum{v in V} phi[v] * cat_veh[v, s] <= max_use[s]; # Numero de vehiculo usados de la categoria s no excede el numero maximo establecido por la compania
s.t. razonPesoCapacidad{v in V, c in C, d in C}: (sum{f in F}  x[f,c,v]) / pes[v,c] = (sum{f in F}  x[f,d,v]) / pes[v,d];  # Razon peso transportado / capacidad de transporte peso

/*
Datos modelo pequeno:
- 3 Vehiculos
- 3 compatimientos
- 3 cargas
- 3 categorias de vehiculo
*/

data;

set V:= v1 v2 v3; 
set C:= c1 c2 c3; 
set F:= f1 f2 f3; 
set S:= s1 s2 s3; 

# Capacidad volumétrica de compartimiento c de vehículo v
param vol: c1 c2 c3 :=  
		v1 20 15 30
		v2 18 17.5 25
		v3 22 20 30; 

# Capacidad de carga de compartimiento c de vehículo v	
param pes: c1 c2 c3 :=
		v1 210 180 390
		v2 188 175 280
		v3 221 210 301;   

# densidad (Kg/m3) de carga f
param den:= f1 1.23 f3 10 f2 4.5; 

# Cantidad (Kg) de carga f disponible para transportar	
param oferta:= f1 1200 f2 570 f3 887; 

# ganancia ($/Kg) obtenida por unidad transportada de carga f
param gan:= f1 20 f3 31 f2 21.8; 

# costo fijo de transportar carga f en vehículo v (independiente de la cantidad transportada)
param cfc: v1 v2 v3 :=  
		f1 20 25 21
		f2 18 17.5 20
		f3 22 20 21; 


# 1 si carga f no puede transportarse en el mismo compartimiento que la carga g; 0  e.o.c.
param restc default 0:= [f1, f3] 1; 
# 1 si se debe pagar seguro por transportar cargas f y g en el mismo vehículo; 0  e.o.c.
param seguro default 0:=  [f1, f3] 1; 
# Valor del seguro que se debe pagar si se va a transportar cargas f y g en el mismo vehículo
param valor_seguro default 0:= [f1, f3] 555; 
# 1 si está prohibido transportar cargas f y g en el mismo vehículo; 0  e.o.c.
param ban default 0:= [f1, f2] 1; 
# 1 si vehículo v pertenece a la categoría s; 0  e.o.c.
param cat_veh: s1 s2 s3 :=  
			v1 1 1 0
			v2 1 0 1
			v3 1 1 1;
# número máximo de vehículos de categoría s que pueden ser usados para transporte
param max_use default 1; 

end;




