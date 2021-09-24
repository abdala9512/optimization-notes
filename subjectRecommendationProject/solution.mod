set M; # MAterias
set S:={1..15}; # Semestres
set MT:={"media", "completa"}; # Matriculas
set EF;


param nucleo{M} default 0;
param creditosMateria{M};
param maxCreditos{MT};
param minCreditos{MT};
param prerrequisito{i in M, j in M} default 0;
param enfasisElegidos{EF};
param enfasisElegido{EF};
param pertenceEnfasis{M,EF} default 0;
param credMinimosCursar{M};
param program:="analitica"


param K:= sum{m in M} creditosMateria[m];



# Variables de desicion
var estudiar{S} binary;
var semestre{S, MT} binary;
var materiaInscrita{M,S} binary;
var creditoCursado{S} integer>=0;
var materiaEnSemestre{M}>=0;

if program =="industrial" then
	table data IN "CSV" "materiasIngenieriaIndustrial.csv": M <-  [MATERIA], creditosMateria~N_CREDITOS;
	table data IN "CSV" "materiasNucleoIngenieriaIndustrial.csv": [MATERIA], nucleo~ES_NUCLEO;
	table data IN "CSV" "enfasisIngIndustrial.csv": EF <- [ENFASIS];
	table data IN "CSV" "materiasEnfasisIngIndustrial.csv": [MATERIA, ENFASIS], pertenceEnfasis~PERTENECE;
	table data IN "CSV" "prerrequisitosIngIndustrial.csv":[MATERIA_I,MATERIA_J], prerrequisito~ES_PRERREQUISITO;
	table data IN "CSV" "creditosParaCursarMateriaIngIndustrial.csv": [MATERIA], credMinimosCursar~CREDITOS_MINIMOS;
else
	table data IN "CSV" "materiasMaestriaAnalitica.csv": M <- [MATERIA], creditosMateria~N_CREDITOS;
	table data IN "CSV" "materiasMaestriaAnalitica.csv": [MATERIA], nucleo~ES_NUCLEO;
	table data IN "CSV" "enfasisMaestriaAnalitica.csv": EF <- [ENFASIS];
	table data IN "CSV" "enfasisMaestriaAnalitica.csv": [MATERIA, ENFASIS], pertenceEnfasis~PERTENECE;
	table data IN "CSV" "prerrequisitosMaestriaAnalitica.csv": [MATERIA_I,MATERIA_J], prerrequisito~ES_PRERREQUISITO;
	table data IN "CSV" "creditosParaCursarMateriaAnalitica.csv": [MATERIA], credMinimosCursar~CREDITOS_MINIMOS;


display {m in M} m;
display K;
display {i in M, j in M} prerrequisito[i,j];
display {m in M, ef in EF} pertenceEnfasis[m, ef];


# Funcion objectivo
minimize fObj: sum{s in S} estudiar[s];

# Restricciones

# Maximo numero de matriculas se decidimos estudiar
s.t. MAX_TIPO_MATRICULAS {s in S}: sum{mt in MT} semestre[s, mt] <= estudiar[s];

# Minimno y Max. numero de creditos por semestre
s.t. MIN_CREDITOS_SEMESTRE {s in S}: sum{m in M} materiaInscrita[m,s] * creditosMateria[m]  >=  sum{mt in MT} minCreditos[mt] * semestre[s, mt];
									 
s.t. MAX_CREDITOS_SEMESTRE {s in S}: sum{m in M} materiaInscrita[m,s] * creditosMateria[m]  <= sum{mt in MT}  maxCreditos[mt] * semestre[s, mt];


# Cursa nucleo fundamental
s.t. CURSA_TODAS_MATERIAS {m in M}: sum{s in S} materiaInscrita[m,s]=1;

# No ver el semestre n antes de haber visto el semestre n-1
s.t. SEMESTRES_EN_ORDEN {s in S:s>2}: sum{mt in MT} semestre[s,mt] <= sum{mt in MT} semestre[s-1,mt];


# Relacion Materia Semestre
s.t. RELACION_MATERIA_SEMESTRE {m in M}: materiaEnSemestre[m] = sum{s in S} materiaInscrita[m,s] * s;

# Prerequisitos
s.t. CUMPLIMIENTO_PRERREQUISITOS {i in M, j in M}: materiaEnSemestre[i]<= (materiaEnSemestre[j]-1) + (1 - (prerrequisito[i,j])) * K;

# Para ver la materia se debe tener el minimo de creditos cursados
s.t. CUMPLIMIENTO_CREDITOS_MINIMOS  {m in M,s in S}: creditoCursado[s] >= credMinimosCursar[m] - (1-materiaInscrita[m,s]) * K;

s.t. CREDITOS_APROBADOS_PRIMER_SEMESRE: creditoCursado[1]=0;
s.t. CALCULO_CREDITOS_APROBADOS  {sa in S:sa>1}: sum{m in M, s in S:s<sa} materiaInscrita[m,s] * creditosMateria[m] = creditoCursado[sa];



solve;

printf "\nTotal creditos obligatorias: %f\n", sum{s in S, m in M} materiaInscrita[m,s] * creditosMateria[m];
printf "\nTotal creditos: %f\n", sum{s in S, m in M} materiaInscrita[m,s] * creditosMateria[m]; 
								 
printf "\n";
for {s in S,m in M}{
	printf if materiaInscrita[m,s] =1 then "Se estudia en el semestre " &s& " " &m& "\n" else "";
}


data;

param maxCreditos:=
	"media" 10
	"completa" 16;
param minCreditos:=
	"media" 1
	"completa" 11;
	
param enfasisElegido:=
"Enfasis logística"		1
"Enfasis producción"	0
"Enfasis Tecnología"	1
"Enfasis Metodos"		0
"Enfasis fomento"		0;

end;
