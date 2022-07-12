#!/usr/bin/gawk -f

BEGIN {
{FS=","} 
{OFS=","}
}
{
if (NR==1) {print ($1,$2,$10,$13,$14,$15,$19,$20,$21)}

else {
	substring = "\""
	printf ($1",");
	if ($2==1) {printf ("Sunday,")}
	else if ($2==2) {printf ("Moday,")}
	else if ($2==3) {printf ("Tuesday,")}
	else if ($2==4) {printf ("Wednesday,")}
	else if ($2==5) {printf ("Thursday,")}
	else if ($2==6) {printf ("Friday,")}
	else {printf ("Saturday,")}
	{gsub(substring, "", $10); printf $10","}
	{gsub(substring, "", $13); printf $13","}
	{gsub(substring, "", $14); printf $14","}
	printf ($15",")
	printf ($19",")
	printf ($20",")
	printf ($21*1.852"\n")
}
}
