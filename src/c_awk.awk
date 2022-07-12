#!/usr/bin/awk -f

#He tartado de hacer un script genérico, el archivo debe contener unicamente datos numéricos, separados por coma 
#y los valores nulos deben estar representados por la cadena de texto "null", siempre se pueden hacer pequeñas
#modificaciones. 

function abs(x) {return ((x>0.0) ? -x:x)}

BEGIN {
	FS=",";
	print "Statisctics of numeric data:";
	
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
	for (i=1;i<=max_nf;i++){
		mean=0.0;
		sum=0.0;
		counter=0.0;
		max=0.0;
		min=9999999999;
		repeated=0.0;
		value_most_repeated=0.0;
		sum_sq=0.0;
		sd=0.0;
		dev_med=0.0;
		sum_cub=0.0;
		sum_cuar=0.0;
		sum_q=0.0;
		
		printf "--------------------------------------------------\n"
		printf "field\t"names[i]"\n"
		printf "--------------------------------------------------\n" 
		for (j=1;j<=max_nr;j++) {
			if (mat[i,j]!="") {
				if (mat[i,j]>max) {max=mat[i,j]; row_max=j}
				if (mat[i,j]<min) {min=mat[i,j]; row_min=j}
				counter++;
				sum+=mat[i,j];
				sum_q+=(mat[i,j])**2
				pre_sorted[j]=mat[i,j]
				mode[mat[i,j]]++
			}
		}
		
		#assort y assorti para ordenar claves o valores
		n=asort(pre_sorted, sorted, "@val_num_asc")
		mean=(sum/n)
		for (l=1;l<=n;l++) {
			#vardos+=((sorted[l]-(sum/n))**2)/n;
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
		printf "field_"names[i]"_["i"]_Número_de_datos: %.0f\n", n
		printf "field_"names[i]"_["i"]_Número_de_nulls: %.0f\n", (NR-1)-n #NR-counter
		printf "\n"
		printf "field_"names[i]"_["i"]_media: %.18f\n",mean
		printf "field_"names[i]"_["i"]_varianza: %.18f\n",sum_sq/n
		printf "field_"names[i]"_["i"]_varianza(n+1): %.18f\n",(sum_sq/(n+1))
		printf "field_"names[i]"_["i"]_varianza(n+2): %.18f\n",(sum_sq/(n-1))
		printf "field_"names[i]"_["i"]_desviación_estándar: %.18f\n", sd
		printf "field_"names[i]"_["i"]_sumatorio: %.18f\n", sum
		printf "field_"names[i]"_["i"]_suma_de_cuadrados: %.18f\n", sum_sq
		printf "field_"names[i]"_["i"]_suma_de_cuadrados_mo_corregida: %.18f\n", sum_q
		printf "field_"names[i]"_["i"]_deviación_media: %.18f\n",-1*(dev_med/n)
		printf "field_"names[i]"_["i"]_asimetría: %.18f\n",((sum_cub)/((n)*(sd)**3))
		printf "field_"names[i]"_["i"]_curtosis: %.18f\n",((sum_cuar)/(n*((sd)**4)))
		printf "\n"
		printf "field_"names[i]"_["i"]_valor_máximo["row_max"]: %.18f\n", max #sorted[n]
		printf "field_"names[i]"_["i"]_valor_mínimo["row_min"]: %.18f\n", min #sorted[1]
		printf "field_"names[i]"_["i"]_q1: %.18f\n", q_one
		printf "field_"names[i]"_["i"]_mediana(q2): %.18f\n", mediana
		printf "field_"names[i]"_["i"]_q3: %.18f\n", q_three
		printf "field_"names[i]"_["i"]_máxima_repetición: %.0f\n", repeated
		if (repeated>1) {printf "field_"names[i]"_["i"]_most_repeated_value: %f\n", value_most_repeated}
		else {printf "There are not repeated values\n"}
		
		delete sorted
		delete mode
		delete pre_sorted
	}
	printf "--------------------------------------------------\n"
	printf "                      END\n"
	printf "--------------------------------------------------\n" 
}
















