/*
Proyecto Optimizacion Avanzada

Miguel Arquez Abdala

Septiembre 2021

*/

set M; # MAterias
set S:={1..15}; # Semestres
set MT:={"media", "completa"}; # Matriculas
set E; # Electivas
set CM; # Complementarias


param creditosMateria{M};
param creditosElectiva{E};
param creditosComplementaria{CM};
param maxCreditos{MT};
param minCreditos{MT};
param prerrequisito{i in M, j in M} default 0;


param totalCreditosElectivas:=16;
param totalCreditosComplementarias:=15;

param K:= sum{m in M} creditosMateria[m] + sum{e in E} creditosElectiva[e] + sum{cm in CM} creditosComplementaria[cm];



# Variables de desicion
var estudiar{S} binary;
var semestre{S, MT} binary;
var materiaInscrita{M,S} binary;
var electivaInscrita{E,S} binary;
var complementariaInscrita{CM, S} binary;
var materiaEnSemestre{M}>=0;



table data IN "CSV" "materiasMaestriaAnalitica.csv": M <- [MATERIA], creditosMateria~N_CREDITOS;
table data IN "CSV" "electivasMaestriaAnalitica.csv": E <- [ELECTIVA], creditosElectiva~N_CREDITOS;
table data IN "CSV" "complementariasMaestriaAnalitica.csv": CM <- [COMPLEMENTARIA], creditosComplementaria~N_CREDITOS;
table data IN "CSV" "prerrequisitosMaestriaAnalitica.csv": [MATERIA_I,MATERIA_J], prerrequisito~ES_PRERREQUISITO;


display {m in M} m;
display {e in E} e;
display {cm in CM} cm;
display K;

# Funcion objectivo
minimize fObj: sum{s in S} estudiar[s];


# Restricciones

# Maximo numero de matriculas se decidimos estudiar
s.t. MAX_TIPO_MATRICULAS {s in S}: sum{mt in MT} semestre[s, mt] <= estudiar[s];

# Minimno y Max. numero de creditos por semestre
s.t. MIN_CREDITOS_SEMESTRE {s in S}: sum{m in M} materiaInscrita[m,s] * creditosMateria[m] +
									 sum{e in E} electivaInscrita[e,s] * creditosElectiva[e] +
									 sum{cm in CM} complementariaInscrita[cm, s] * creditosComplementaria[cm] >=  sum{mt in MT} minCreditos[mt] * semestre[s, mt];
									 
s.t. MAX_CREDITOS_SEMESTRE {s in S}: sum{m in M} materiaInscrita[m,s] * creditosMateria[m] +
									 sum{e in E} electivaInscrita[e,s] * creditosElectiva[e] +
									 sum{cm in CM} complementariaInscrita[cm, s] * creditosComplementaria[cm] <= sum{mt in MT}  maxCreditos[mt] * semestre[s, mt];


# Cursa nucleo fundamental
s.t. CURSA_TODAS_MATERIAS {m in M}: sum{s in S} materiaInscrita[m,s]=1;


# Cursa electivas y complementarias necesarias para grado
s.t. CURSA_ELECTIVAS: sum{e in E, s in S} electivaInscrita[e,s] * creditosElectiva[e] >= totalCreditosElectivas;
s.t. CURSA_COMPLEMENTARIAS: sum{cm in CM, s in S} complementariaInscrita[cm,s] * creditosComplementaria[cm] >= totalCreditosComplementarias;


# No ver el semestre n antes de haber visto el semestre n-1
s.t. SEMESTRES_EN_ORDEN {s in S:s>2}: sum{mt in MT} semestre[s,mt] <= sum{mt in MT} semestre[s-1,mt];


# Relacion Materia Semestre
s.t. RELACION_MATERIA_SEMESTRE {m in M}: materiaEnSemestre[m] = sum{s in S} materiaInscrita[m,s] * s;

# Prerequisitos
s.t. CUMPLIMIENTO_PRERREQUISITOS {i in M, j in M}: materiaEnSemestre[i]<= (materiaEnSemestre[j]-1) + (1 - (prerrequisito[j,i])) * K;



data;

param maxCreditos:=
	"media" 10
	"completa" 20;
param minCreditos:=
"media" 1
"completa" 11;

end;



