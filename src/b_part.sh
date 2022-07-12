#!/bin/bash

#Vamos a hacer unos pequeños ajustes que nos servirán luego:
#Primero eliminamos el salto de linea (concretamente carriage return \r) bastante incomodo en algunos casos y aprovechamos
#para generar un nuevo archivo sobre el que realizaremos todas las transformaciones (data_tr.csv):
tr -d '\r' < water_potability.csv > data_tr.csv

#Sustituimos los valores ausentes por la cadena de texto "null" puede ser de utilidad en un futuro:
#Y aprovechamos y corregimos posibles valores incorrectos, conocemos que la escala de pH es de 1 a 14,
#cualquier valor fuera de ese rango lo convertiremos en "null".

awk 'BEGIN {FS=OFS=","} 
	NR>1{for(i=1; i<=NF; i++) {
		if(length($i) == 0) {$i = "null"}}
		{if ($1<1 || $1>14) {$1="null"}}
	};1' data_tr.csv > tmpout && mv tmpout data_tr.csv


#Vamos a añadir un campo con el número de valores que son null por registro y mostrar por pantalla los 20
#registros con más datos nulos:
awk 'BEGIN {FS=OFS=","} {
	for(i=1; i<=NF; i++) {
		if($i=="null") {counter++; }
		}
	} 
	{$++NF=counter; counter=0};1' data_tr.csv > tmpout && mv tmpout data_tr.csv
	

awk 'BEGIN {FS=OFS=","} 
	NR==1{$11="nulls"}1' data_tr.csv > tmpout && mv tmpout data_tr.csv


awk 'BEGIN {FS=OFS=","} 
	NR==1{$++NF="id"} 
	NR>1{i++; $++NF=i}1' data_tr.csv > tmpout && mv tmpout data_tr.csv
	

echo "-------------------------------------------------------------"
echo "Los registros con mayor número de valores nulos son:"
echo ""

sort -t$',' -k11 -rn data_tr.csv | head -20 - | awk 'BEGIN {FS=OFS=","} {if ($12>999) {
					print "ID: "$12"\tnumber nulls: "$11} 
				else 
					{print "ID: "$12"\t\tnumber nulls: "$11}}' -
echo "-------------------------------------------------------------"
echo ""

#Vamos a crear un conjunto de datos que contenga unicamente los datos numéricos
cut -d, -f1-9 data_tr.csv > data_numeric.csv


#También pdemos mostrar graficamente el número de valores nulos por cada campo:
#Tras numerosas pruebas no he conseguido crear el plot sin crear un archivo antes:
#He probado con arrays, awk dentro de gnuplot creando variables globales... pero los resultados no han sido buenos.

awk 'BEGIN {FS=OFS=","} NR==1{for (i=1;i<=NF;i++) {a[i]=0; b[i]=$i}}
	NR!=1{for (i=1;i<=NF;i++){if ($i=="null") {a[i]++}}} END{for (j in a) {print b[j]","a[j]}}' data_numeric.csv > plot_nulls.csv


#Lo imprimimos en consola
echo "-------------------------------------------------------------"
echo "El número de valores nulos por campo es:"
echo ""
awk 'BEGIN {FS=OFS=","} NR==1{for (i=1;i<=NF;i++) {a[i]=0; b[i]=$i}}
	NR!=1{for (i=1;i<=NF;i++){if ($i=="null") {a[i]++}}} END{
		for (j in a) {
			if (length(b[j])>=15) {print b[j]":\t"a[j]}
			else if (length(b[j])>=7) {print b[j]":\t\t"a[j]}
			else {print b[j]":\t\t\t"a[j]}
		}
		}' data_numeric.csv 

echo ""
echo "-------------------------------------------------------------"
echo ""
echo "-------------------------------------------------------------"	
echo ""
#Y mostramos graficamente:
gnuplot -persist <<-EOFMarker
	set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
	set term png size 1200, 1200
	set output 'nulls_by_attribute.png'
	unset key
	set datafile separator ","
	set yrange [0:*]
	set xrange [-1:*]
	set style fill solid
	unset key
	set title "Valores nulos por atributo"
	plot "plot_nulls.csv" u 0:2:xtic(1) smooth freq w boxes lc rgb"green" title '1'
EOFMarker

#También mostraremos la distribución de todas las variables graficamente:

gnuplot -persist <<-EOFMarker
	set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
	set term png size 2500, 2500
	set output 'distribution_data.png'
	data="data_tr.csv"
	set key autotitle columnhead
	unset key
	set datafile separator ","
	set title 
	set multiplot layout 4,3 rowsfirst title "Distribucion de todos los datos originales\n" font ",20"
	do for [i=1:10] {
	getTitle(colNum)=system(sprintf("head -n1 '%s' | cut -f%d -d','", data, colNum+1))
		stats data using i nooutput
		n=50 
		max=STATS_max 
		min=STATS_min 
		width=(max-min)/n
		hist(x,width)=width*floor(x/width)+width/2.0
		set xrange [min:max]
		set yrange [0:]
		set offset graph 0.05,0.05,0.05,0.0
		set xtics min,(max-min)/5,max
		set boxwidth width*0.9
		set style fill solid 0.5
		set tics out nomirror
		set ylabel "Frequency"
		set xlabel getTitle(i-1)
		set xrange [min:max]
		set yrange [0:]
		set xtics min,(max-min)/5,max
		set size 0.33,0.25
		plot data u (hist(column(i),width)):(1.0) smooth freq w boxes lc rgb"green"
	}
	unset multiplot
EOFMarker



#Y un diagrama de cajas y bigotes para visualizar la prsenecia de outliers, para esto primero seleccionaremos los valores numéricos que nos interesan del dataset
#También podríamos haber filtrado als columnas deseadas en la iteración pero esta transformación también nos servira despues:

#sort -nrk1,1 data_tr.csv | head -1 |cut -d ',' -f1



gnuplot -persist <<-EOFMarker
	set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
	set term png size 1200, 1200
	set output 'boxplot_data.png'
	set key autotitle columnhead
	unset key
	data="data_numeric.csv"
	getTitle(colNum)=system(sprintf("head -n1 '%s' | cut -f%d -d','", data, colNum+1))
	set datafile separator ","
	set style data boxplot
	set style fill solid 0.5 border -1
	set style boxplot outliers pointtype 7
	set boxwidth 0.5
	set multiplot layout 3,3 rowsfirst title "Boxplot de todos los datos\n" font ",20"
	set xtics nomirror
	set ytics nomirror
	do for [i=1:9] {
		set xtics (i 1) scale 0.0
		set xlabel getTitle(i-1)
		plot data using (0):i with boxplot
	}
	unset multiplot
EOFMarker

#Una matriz de dispersión o scatter matrix con gnuplot, un poco básica, pero cumple su función:
gnuplot -persist <<-EOFMarker
	set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
	set term png size 3000, 3000
	set output 'dispersion_data.png'
	set key autotitle columnhead
	unset key
	set datafile separator ","
	data="data_numeric.csv"
	set multiplot layout 9,9 rowsfirst
	set ytics auto
	
	set size 0.8,1
	do for [i=1:9] {
		do for [j=1:9] {
			set size 0.12,0.12
			plot data using i:j 
		}
	}
	unset multiplot
	unset output
EOFMarker


#El dataset elegido no tiene variables categóricas, pero he tratado de crear una función con una transformación muy común en estos casos
#La función denominada one hot encoder, para dividir una variable categórica en distintos campos y pasarla a binario.
#He tratado de hacerla genérica para poder emplearla en cualquier datast, deberíamos introducir la columna que deseamos dividir 
#en variables binarias, el nombre del archivo a transformar y despùés modificar los nombres:


function one_hot_encoder() {
	awk -v field=$1 'BEGIN {FS=OFS=","} NR!=1{a[$field]=1; b[i++]=$field} 
		END{
			for (i in a) {
				printf"field_"i","
			}
			printf"\n"
			for (i in b) {
				for (j in a){
					if (b[i]==j) {printf"1,"}
					else {printf"0,"}
			}
			printf"\n"
			}
		}' $2 | sed 's/,$//' | paste -d, $2 - > data_one_hot_encoder.csv
}
	
one_hot_encoder 11 data_tr.csv

#podemos probar creando un atributo categórico en un archivo de prueba y comprobar que funciona correctamente
#Lo dejaré comentado para no sobrescribir el archivo ni crear demasiados.

#awk -F, '{OFS=","} NR==1{$++NF="field_categoric"}
#		    NR>1{if (NR==14) {$++NF="a"}
#		    	 else if (NR==200) {$++NF="b"}
#		    	 else if (NR%2==0) {$++NF="c"}
#		    	 else {$++NF="d"}}1' data_tr.csv > pruebas.csv
#one_hot_encoder 13 pruebas.csv


#Finalmente eliminaremos los registros con 3 valores nulos, ya que son muy pocos y suponen un 33% de los datos (de un único registro)

awk 'BEGIN {FS=OFS=","} NR==1{print $0} NR!=1{if($11<3) {print $0}}' data_tr.csv > tmpout && mv tmpout data_tr.csv

#sobrescribimos data_numeric con el nuevo número de registros.
cut -d, -f1-9 data_tr.csv > data_numeric.csv

#Se aporta comentado la generación de dos de los plots anteriores en pantalla

#gnuplot -geometry 1000x1000 -persist <<-EOFMarker
#	set terminal x11
#	set key autotitle columnhead
#	unset key
#	set datafile separator ","
#	data="data_numeric.csv"
#	set multiplot layout 9,9 rowsfirst
#	set ytics auto
#	set size 0.8,1
#	#podemos hacerlo por puntos, pero creo que se ve mejor por defecto:
#	#set style line 1 lc rgb '#0060ad' pt 7
#	do for [i=1:9] {
#		do for [j=1:9] {
#			set size 0.12,0.12
#			unset xtics
#			unset ytics
#			plot data using i:j # para imprimir con puntos-> w p ls 1 con set style sin comentar
#		}
#	}
#	unset multiplot
#	unset output
#EOFMarker

#gnuplot -geometry 1000x1000 -persist <<-EOFMarker
#	set terminal x11
#	data="data_tr.csv"
#	set key autotitle columnhead
#	unset key
#	set datafile separator ","
#	set title 
#	set multiplot layout 4,3 rowsfirst title "Distribucion de todos los datos originales\n" font ",20"
#	do for [i=1:10] {
#		getTitle(colNum)=system(sprintf("head -n1 '%s' | cut -f%d -d','", data, colNum+1))
#		stats data using i nooutput
#		n=50 
#		max=STATS_max 
#		min=STATS_min 
#		width=(max-min)/n
#		hist(x,width)=width*floor(x/width)+width/2.0
#		set xrange [min:max]
#		set yrange [0:]
#		set offset graph 0.05,0.05,0.05,0.0
#		set xtics min,(max-min)/5,max
#		set boxwidth width*0.9
#		set style fill solid 0.5
#		set tics out nomirror
#		set ylabel "Frequency"
#		set xlabel getTitle(i-1)
#		plot data u (hist(column(i),width)):(1.0) smooth freq w boxes lc rgb"green"
#	}
#	unset multiplot
#EOFMarker


#gnuplot -geometry 1000x1000 -persist <<-EOFMarker
#	set terminal x11
#	unset key
#	set datafile separator ","
#	set yrange [0:*]
#	set xrange [-1:*]
#	set style fill solid
#	unset key
#	set title "Valores nulos por atributo"
#	plot "plot_nulls.csv" u 0:2:xtic(1) smooth freq w boxes lc rgb"green" title '1'
#EOFMarker

#gnuplot -geometry 1000x1000 -persist <<-EOFMarker
#	set terminal x11
#	set key autotitle columnhead
#	unset key
#	data="data_numeric.csv"
#	getTitle(colNum)=system(sprintf("head -n1 '%s' | cut -f%d -d','", data, colNum+1))
#	set datafile separator ","
#	set style data boxplot
#	set style fill solid 0.5 border -1
#	set style boxplot outliers pointtype 7
#	set boxwidth 0.5
#	set multiplot layout 3,3 rowsfirst title "Boxplot de todos los datos\n" font ",20"
#	set xtics nomirror
#	set ytics nomirror
#	do for [i=1:9] {
#		set xtics (i 1) scale 0.0
#		set xlabel getTitle(i-1)
#		plot data using (0):i with boxplot
#	}
#	unset multiplot
#EOFMarker


#Y ejecutaremos el script awk que nos mostrará toda la información de los datos, al ser un conjunto de datos numéricos, he decidido crear 
# un script que nos muestre información estadística de los datos, similar a las funciones summary() de R o describe() de pandas entre otras
#También serán útiles en las transformaciones que haremos:

./c_awk.awk data_numeric.csv 










