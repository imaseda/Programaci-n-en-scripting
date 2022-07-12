#!/usr/bin/gawk -f

BEGIN {
{FS=","} 
{OFS=","}
{CONVFMT="%.5f"}
}
{
if (NR==1) {print ("Weekday, % delayed, delayed, total flights")}
else {
	if ($2=="Moday") {
		total_monday++;
		if ($6 == "1.00") {
			delay_monday++;
			}
	}
	if ($2=="Tuesday") {
		total_tuesday++;
		if ($6 == "1.00") {
			delay_tuesday++;
			}
	}
	if ($2=="Wednesday") {
		total_wednesday++;
		if ($6 == "1.00") {
			delay_wednesday++;
			}
	}
	if ($2=="Thursday") {
		total_thursday++;
		if ($6 == "1.00") {
			delay_thursday++;
			}
	}
	if ($2=="Friday") {
		total_friday++;
		if ($6 == "1.00") {
			delay_friday++;
			}
	}
	if ($2=="Saturday") {
		total_saturday++;
		if ($6 == "1.00") {
			delay_saturday++;
			}
	}
	if ($2=="Sunday") {
		total_sunday++;
		if ($6 == "1.00") {
			delay_sunday++;
			}
	}
}
}END{
	print("Monday,"(delay_monday/total_monday)*100","delay_monday","total_monday);
	print("Tuesday,"(delay_tuesday/total_tuesday)*100","delay_tuesday","total_tuesday);
	print("Wednesday,"(delay_wednesday/total_wednesday)*100","delay_wednesday","total_wednesday);
	print("Thursday,"(delay_thursday/total_thursday)*100","delay_thursday","total_thursday);
	print("Friday,"(delay_friday/total_friday)*100","delay_friday","total_friday);
	print("Saturday,"(delay_saturday/total_saturday)*100","delay_saturday","total_saturday);
	print("Sunday,"(delay_sunday/total_sunday)*100","delay_sunday","total_sunday)
}
	
