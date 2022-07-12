#Primero ejecutamos "b_part.sh" que hace una primera transformación eliminando el caracter de control retorno de carro,
#asignando valor "null" a los valores ausentes, corrigiendo el atributo pH y nos muestra por pantalla información sobre 
#el conjunto de datos, concretamente veremos los registros con mayor número de valores nulos, el número de valores nulos 
#por atributo, la distribución de nuestros datos y un diagrama de cajas de los mismos. Las gráficas se generan en archivos
#.png por si se lanza desde una terminal sin modo gráfico.
#En este script también se ejecuta "c_awk.awk" mostrandonos todos los cálculos matemáticos realizados en dicho script por
#pantalla y agrupados por atributo.
#En este script también he creado una función que funciona como "one hot encoder", no es útil en nuestro caso, pero me pareció
#interesante añadirla, ya que suele ser una transformación muy típica en algunos datos, se aporta un ejemplo con el campo 
#"nulls" que hemos creado (ya que toma valores entre 0 y 3) también se aportan un ejemplo en el que se hace con una cadena de
#texto, está todo comentado para no crear archivos en exceso.

./b_part.sh

#Ahora ejecutaremos "c_bash.sh" que llevará a cabo una serie de transformaciones, en el script se aportan funciones para
#hacerlo de distintas meneras. Obviamente tenemos que elegir métodos para nuestros datos, pero se han probado todas las funciones
#y su correcto funcionamiento, aparecen comandos comentados para ejecutar distintas funciones, simplemente hanbría que modificar 
#ligeramente el script o llamar a dichas funciones desde la consola.

echo ""
echo "A continuación trataremos los valores nulos y normalizaremos nuestros datos"
echo ""
echo "---------------------------------------------------------------------------"

#Este script también nos mostrará cierta información una vez transformado, comprobaremos que ya no existen valores nulos y
#veremos la distribución de los datos normalizados. De nuevo la gráfica se genera en un archivo .png, misma lógica que antes.
#También se añade una versión modificada del script "c_awk.awk" dentro de "c_bash.sh", para no excederme en el número de archivos 
#y ya que creo que ambos son de utilidad (uno enfocado a mostrarlo por pantalla y otro enfocado a emplear esos datos con facilidad
#en el futuro). Por tanto se añaden todos los cáculos realizados después de las transformaciones a "stats_data.csv", se debe ir
#modificando este archivo en cada transformación para calcular los nuevos valores.  

./c_bash.sh


#Por último ejecutamos el script "d.sh" que genera un archivo .html con información filtrada, debido a la tipología del dataset, 
#he decidido aprovechar mis propios scripta para filtrar datos e imprimirlos en una tabla, quizás no es exactamente lo que se pedia 
#pero me ha parecido interesante filtrar los propios datos generados.

./d.sh > PRAC1.html

#Borramos algunos archivos innecesarios antes de terminar.
rm a.txt
rm b.txt
rm plot_nulls.csv

