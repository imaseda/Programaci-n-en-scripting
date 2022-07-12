#!/bin/bash

#Para esta parte modificaremos ligeramnete el script awk para generar un archivo csv con todos los datos estadísticos de cada variable:
#El objetivo es el tratamiento de valores nulos y la normalización de nuestros datos, para esto  crearé funciones para modificar 
#los datos de una columna determinada, es posible que queramos abordar distintas estrategias en cada columna.

function save_statiistics() {
	awk 'function abs(x) {return ((x>0.0) ? -x:x)}
		BEGIN {
		FS=",";
	
		}
		{CONVFMT="%.18f"}
		NR==1{
			for (i=1;i<=NF;i++){
				names[i]=$i
			}
		}
		NR!=1{
			if (max_nf<NF) {max_nf=NF}
			max_nr=NR
			for (i=1;i<=NF;i++){
				if ($i!="null") {
					mat[i, NR]=$i
				}
			}
		} END {
			printf "field,n,nulls,media,var,var(n+1),var(n-1),sd,sum,sum_sq,sum_cuad,dev_med,asim,curtosis,max,min,q1,q2,q3,max_rep,mode\n"
	
			for (i=1;i<=max_nf;i++){
				mean=0.0;
				sum=0.0;
				counter=0.0;
				max=0.0;
				min=9999999999;
				counter_null=0.0;
				value_most_repeated=0.0;
				repeated=0.0;
				sd=0.0;
				dev_med=0.0;
				sum_cub=0.0;
				sum_cuar=0.0;
				sum_q=0.0;
				sum_sq=0.0;
		
				for (j=1;j<=max_nr;j++) {
					if (mat[i,j]!="") {
						if (mat[i,j]>max) {max=mat[i,j]; row_max=j}
						if (mat[i,j]<min) {min=mat[i,j]; row_min=j}
						counter++;
						sum+=mat[i,j];
						sum_q+=(mat[i,j])**2;
						pre_sorted[j]=mat[i,j];
						mode[mat[i,j]]++
					}
				}

				n=asort(pre_sorted, sorted, "@val_num_asc")
				mean=(sum/n)
				for (l=1;l<=n;l++) {
					dev_med+=abs((sorted[l])-(mean))
					sum_sq+=((sorted[l])-(mean))**2
					sum_cub+=(((sorted[l])-(mean))**3)*mode[sorted[l]]
					sum_cuar+=(((sorted[l])-(mean))**4)*mode[sorted[l]]
				}
		
				if (n%2) {
					mediana=sorted[(n+1)/2];
				}else { 
					mediana=(sorted[(n/2)] + sorted[(n/2)+1])/2.0;
				}
				if (((n+1)/4)%2) {
					q_one=(sorted[int((n+1)/4)] + (((n+1)/4)-(int((n+1)/4)))*(sorted[int((n+1)/4)+1] - sorted[int((n+1)/4)]));
				}else { 
					q_one=sorted[(n+1)/4];
				}
				if ((3*(n+1)/4)%2) {
					q_three=(sorted[int(3*(n+1)/4)] + (((3*(n+1)/4))-(int(3*(n+1)/4)))*(sorted[int(3*(n+1)/4)+1] - sorted[int(3*(n+1)/4)]));
				}else { 
					q_three=sorted[3*(n+1)/4];
				}
				for (w in mode){
					if (mode[w]>repeated) {repeated=mode[w]; value_most_repeated=w}
				}
		
				sd=sqrt(sum_sq/n)
				#printf("field_"i"_varianza: %.18f\n",var)
				printf names[i]","
				printf "%.0f,", n
				printf "%.0f,", ((NR-1)-n)
				printf "%.18f,", mean
				printf "%.18f,", sum_sq/n
				printf "%.18f,",(sum_sq/(n+1))
				printf "%.18f,",(sum_sq/(n-1))
				printf "%.18f,", sd
				printf "%.18f,", sum
				printf "%.18f,", sum_sq
				printf "%.18f,", sum_q
				printf "%.18f,",-1*(dev_med/n)
				printf "%.18f,",((sum_cub)/((n)*(sd)**3))
				printf "%.18f,",((sum_cuar)/(n*((sd)**4)))
				printf "%.18f,", max #sorted[n]
				printf "%.18f,", min #sorted[1]
				printf "%.18f,", q_one
				printf "%.18f,", mediana
				printf "%.18f,", q_three
				printf "%.0f,", repeated
				if (repeated==1) {printf "null\n"}
				else {printf "%.18f\n", value_most_repeated}
		
				delete sorted
				delete mode
				delete pre_sorted
			}
		}' $1 > stats_data.csv
	echo "Las estadísticas de los datos '$1' han sido guardadas en el archivo 'stats_data.csv'."
	echo "-------------------------------------------------------------------------------"
}

save_statiistics data_numeric.csv

#Creamos un nuevo conjunto de datos para conservar la transformación anterior
cat data_numeric.csv > data_tr_2.csv

#----------------------------TRATAMIENTO DATOS NULOS---------------------------------------
#limitamos los decimales a 11, es un detalle que se explica la función norm_standard().
function mean_replace() {
	mean=`awk -v field=$1 'BEGIN {FS=OFS=","} NR==(field+1){printf "%.11f", $4}' stats_data.csv`;
	awk -v field=$1 -v mean=$mean 'BEGIN {FS=OFS=","} NR==1{print $0} NR!=1{if ($field=="null") {$field=mean} {print $0}}' $2 > tmpout && mv tmpout $2;
	echo "Se han sustituido los valores nulos en la columna [$1] por el valor de la media: $mean"
	echo "-------------------------------------------------------------------------------"
}

mean_replace 1 data_tr_2.csv
mean_replace 5 data_tr_2.csv
mean_replace 8 data_tr_2.csv

#cut -d, -f1-9 data_tr_2.csv | ./c_awk.awk -

function median_replace() {
	median=`awk -v field=$1 'BEGIN {FS=OFS=","} NR==(field+1){printf "%.18f", $18}' stats_data.csv`;
	awk -v field=$1 -v median=$median 'BEGIN {FS=OFS=","} NR==1{print $0} NR!=1{if ($field=="null") {$field=median} {print $0}}' $2 > tmpout && mv tmpout $2;
	echo "Se han sustituido los valores nulos en la columna [$1] por el valor de la mediana: $median"
	echo "-------------------------------------------------------------------------------"
}

#median_replace 1 data_tr_2.csv
#median_replace 5 data_tr_2.csv
#median_replace 8 data_tr_2.csv
#cut -d, -f1-9 data_tr_2.csv | ./c_awk.awk -

function mode_replace() {
	mode=$(awk -v field=$1 'BEGIN {FS=OFS=","} NR==(field+1){print $21}' stats_data.csv);
	if (("$mode"=="null")); then
		echo "No existen valores repetidos en dicho campo, por tanto no es posible la transformación"
		echo "-------------------------------------------------------------------------------"
	else
		awk -v field=$1 -v mode=$mode 'BEGIN {FS=OFS=","} NR==1{print $0} NR!=1{if ($field=="null") {$field=mode} {print $0}}' $2 > tmpout && mv tmpout $2;
		echo "Se han sustituido los valores nulos en la columna [$1] por el valor de la moda: $mode"
		echo "-------------------------------------------------------------------------------"
	fi
}

#mode_replace 1 data_tr_2.csv

function replace_value() {
	value=$3
	awk -v field=$1 -v value=$value 'BEGIN {FS=OFS=","} NR==1{print $0} NR!=1{if ($field=="null") {$field=value} {print $0}}' $2 > tmpout && mv tmpout $2;
	echo "Se han sustituido los valores nulos en la columna [$1] por el valor deseado: $value"
	echo "-------------------------------------------------------------------------------"
}


#replace_value 1 data_tr_2.csv 5.86
#replace_value 5 data_tr_2.csv 5.25
#replace_value 8 data_tr_2.csv 69.65
#cut -d, -f1-9 data_tr_2.csv | ./c_awk.awk -

#También es común en conjuntos de datos ordenados, por ejemplo, en edades, rempazar por el último valor, no lo ejecutaré en 
#este caso pero podría ser algo así (si la primera fila tiene valor nulo, la variable se inicializa en 0, podríamos decidir
#un valor inicial dependiendo de las necesidades:

function replace_last_value() {
	awk -v field=$1 'BEGIN {FS=OFS=","} NR==1{print $0} NR!=1{if ($field=="null"){$field=last_value; last_value=$field} {print $0}}' $2 > tmpout && mv tmpout $2;
}


#----------------------------NORMALIZACIÓN ESTADÍSTICA---------------------------------------
#Mismo proceso, creando distintas funciones según los métodos empleados, también lo haremos por columna, mismo motivo explicado 
#al comienzo, podemos decidir distintas estrategias para cada campo.


save_statiistics data_tr_2.csv


function norm_max_min() {
	a=($(awk -v field=$1 'BEGIN {FS=OFS=","} NR==(field+1){print $15; print $16}' stats_data.csv));
	max="${a[0]}";
	min="${a[1]}";
	awk -v field=$1 -v max=$max -v min=$min 'BEGIN {FS=OFS=","} NR==1{print $0} NR!=1{$field=(($field-min)/(max-min)); print $0}' $2 > tmpout && mv tmpout $2;
	echo "Se ha nomalizado por max-min la columna [$1], formula (x-min)/(max-min)"
	echo "max= $max	min= $min"
	echo "-------------------------------------------------------------------------------"
}

#for i in {1..9};do norm_max_min $i data_tr_2.csv;done

#Nos vemos obligados a limitar los decimales, ya que admite un número determinado de dígitos, entre decimales 
#y enteros, si queremos obtener 0 en los valores sustituidos por la media (sería lo correcto), debemos limitar los decimales,
# he probado distintas formas de aumentarlo ({CONVFMT="%.18f"} por ejemplo) pero no he obtenido el resultado deseado.

function norm_standard() {
	a=($(awk -v field=$1 'BEGIN {FS=OFS=","} NR==(field+1){printf "%.11f\n", $4; printf "%.11f\n", $8}' stats_data.csv));
	mean="${a[0]}";
	sd="${a[1]}";
	awk -v field=$1 -v mean=$mean -v sd=$sd 'BEGIN {FS=OFS=","} NR==1{print $0} NR!=1{$field=(($field-mean)/sd); print $0}' $2 > tmpout && mv tmpout $2;
	echo "Se ha nomalizado por escalado estándar la columna [$1], formula (x-mean)/std_dev"
	echo "mean= $mean	sd= $sd"
	echo "-------------------------------------------------------------------------------"
}

for i in {1..9};do norm_standard $i data_tr_2.csv;done

save_statiistics data_tr_2.csv

#Finalmente podemos observar la distribución de nuestros datos depués de las transformaciones, y comprobar que no existan valores nulos:

echo "-------------------------------------------------------------"
echo "Después de la transformación no existen valores nulos:"
echo ""
awk 'BEGIN {FS=OFS=","} NR==1{for (i=1;i<=NF;i++) {a[i]=0; b[i]=$i}}
	NR!=1{for (i=1;i<=NF;i++){if ($i=="null") {a[i]++}}} END{
		for (j in a) {
			if (length(b[j])>=15) {print b[j]":\t"a[j]}
			else if (length(b[j])>=7) {print b[j]":\t\t"a[j]}
			else {print b[j]":\t\t\t"a[j]}
		}
		}' data_tr_2.csv

echo ""
echo "-------------------------------------------------------------"
echo "Podemos ver todas las gráficas generadas en archivos .png en nuestra carpeta."
echo "-------------------------------------------------------------"	
echo "El análisis y transformación han finalizado"


gnuplot -persist <<-EOFMarker
	set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
	set term png size 1500, 1500
	set output 'distribution_after_imputation_data.png'
	data="data_tr_2.csv"
	set key autotitle columnhead
	unset key
	set datafile separator ","
	#los acentos no se muestran correctamente
	set multiplot layout 3,3 rowsfirst title "Distribucion depues de tartar los datos\n" font ",20"
	unset title
	do for [i=1:9] {
		getTitle(colNum)=system(sprintf("head -n1 '%s' | cut -f%d -d','", data, colNum+1))
		stats data using i nooutput
		max=STATS_max 
		min=STATS_min
		set xlabel getTitle(i-1)
		n=50 
		width=(max-min)/n
		hist(x,width)=width*floor(x/width)+width/2.0
		#Debemos añadir [*:*] para detectar valores negativos
		set xrange [*:*]
		set yrange [0:]
		set offset graph 0.05,0.05,0.05,0.0
		set boxwidth width*0.9
		set style fill solid 0.5
		set tics out nomirror
		set xlabel getTitle(i-1)
		set ylabel "Frequency"
		plot data u (hist(column(i),width)):(1.0) smooth freq w boxes lc rgb"green"
	}
	unset multiplot
EOFMarker












