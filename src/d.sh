#!/bin/bash

#awk 'BEGIN {FS=OFS=","} NR==1{print $0} NR>1{if ($10==1) {print $0}}' data_tr.csv | cut -d, -f1-9  > data_numeric_potable.csv
#awk 'BEGIN {FS=OFS=","} NR==1{print $0} NR>1{if ($10==0) {print $0}}' data_tr.csv | cut -d, -f1-9  > data_numeric_no_potable.csv

#./c_awk.awk data_numeric_potable.csv > a.txt
#./c_awk.awk data_numeric_no_potable.csv > b.txt

awk 'BEGIN {FS=OFS=","} NR==1{print $0} NR>1{if ($10==1) {print $0}}' data_tr.csv | cut -d, -f1-9 | ./c_awk.awk - > a.txt
awk 'BEGIN {FS=OFS=","} NR==1{print $0} NR>1{if ($10==0) {print $0}}' data_tr.csv | cut -d, -f1-9 | ./c_awk.awk - > b.txt

echo "<!DOCTYPE html>"
echo "<html>"
echo "	<head>"
echo "		<title>PROGRAMACIÓN EN SCRIPTING PRAC 1</title>"
echo "	</head>"
echo "		<body>"
echo "			<h1>WATHER QUALITY DATASET</h1>
			<h3>El conjunto de datos seleccionado nos ofrece una serie de métricas de las propiedades 
			de distintas muestras de agua y si son potables o no, al ser un conjunto de datos numérico,
			sin datos categóricos, no ofrece muchas posibilidades de prersentar los datos agrupados ni
			filtrados, tenemos el unico atributo categórico es el campo Potability, que nos dice si el
			algua es potable o no, por tanto, he decidido aprovechar los datos matemáticos calculados
			en los scripts creados y mostrar una tabla con las diferencias entre las 2 etiquetas mencionadas
			(potable y no potable), de esta forma obtenemos un informe en formato html5 de los datos,
			rapidamente podemos apreciar si existe alguna diferencia significativa.</h3>"
echo "			<h3>WATHER QUALITY DATASET</h3>"
echo "		<table border='2px'>"
echo "		<tr><td style='text-align:center;color:white;background-color:black'; colspan='3'><span style='font-weight:bold'>AGUA POTABLE</span></td><td style='text-align:center;color:white;background-color:black'; colspan='3'><span style='font-weight:bold'>AGUA NO POTABLE</span></td></tr>"

input1="a.txt"
input2="b.txt"
#input1=$(awk 'BEGIN {FS=OFS=","} NR==1{print $0} NR>1{if ($10==1) {print $0}}' data_tr.csv | cut -d, -f1-9 | ./c_awk.awk -)
#input2=$(awk 'BEGIN {FS=OFS=","} NR==1{print $0} NR>1{if ($10==0) {print $0}}' data_tr.csv | cut -d, -f1-9 | ./c_awk.awk -)

i=1
name_old1=""
name_old2=""

while IFS= read -r line1 && IFS= read -r line2 <&3
	do
		name1=`echo $line1 | grep "field_" | cut -d" " -f1 | tr -d "\:" | sed 's/field_//; s/_\[[[:digit:]]\]_/ /' | cut -d" " -f1 | tr -s '_' ' '`
		data1=`echo $line1 | grep "field_" | cut -d" " -f1 | tr -d "\:" | sed 's/field_//; s/_\[[[:digit:]]\]_/ /' | cut -d" " -f2 | tr -s '_' ' '`
		value1=`echo $line1 | grep "field_" | cut -d" " -f2`
		name2=`echo $line2 | grep "field_" | cut -d" " -f1 | tr -d "\:" | sed 's/field_//; s/_\[[[:digit:]]\]_/ /' | cut -d" " -f1 | tr -s '_' ' '`
		data2=`echo $line2 | grep "field_" | cut -d" " -f1 | tr -d "\:" | sed 's/field_//; s/_\[[[:digit:]]\]_/ /' | cut -d" " -f2 | tr -s '_' ' '`
		value2=`echo $line2 | grep "field_" | cut -d" " -f2`
		if [ -z "$name1" ] 
		then
			continue
		elif [ "$name1" = "$name_old1" ] 
		then
			echo "			<tr><td style='background-color:LightGrey'>$data1</td><td style='background-color:LightGrey'>$value1</td><td style='background-color:LightGrey'>$data2</td><td style='background-color:LightGrey'>$value2</td></tr>"
		else
			echo "			<tr><td style='text-align:center;color:white;background-color:black'; rowspan='19'><span style='font-weight:bold'>$name1</span></td><td>$data1</td><td>$value1</td><td style='text-align:center;color:white;background-color:black'; rowspan='19'><span style='font-weight:bold'>$name2</span></td><td>$data2</td><td>$value2</td></tr>"
		fi
		name_old1=$name1

done < $input1 3<$input2
#done < <(awk 'BEGIN {FS=OFS=","} NR==1{print $0} NR>1{if ($10==1) {print $0}}' data_tr.csv | cut -d, -f1-9 | ./c_awk.awk -) 3< <(awk 'BEGIN {FS=OFS=","} NR==1{print $0} NR>1{if ($10==0) {print #$0}}' data_tr.csv | cut -d, -f1-9 | ./c_awk.awk -)

echo "		</body>"

echo "	</html>"
