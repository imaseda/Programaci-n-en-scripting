# Programaci-n-en-scripting

## Descripción

Distinguimos dos objetivos principales dentro del repositorio:

Una primera parte en la que se analizan los datos de retrasos de aviones en distintos aeropuertos y se muestran por pantalla en dos formatos:
- Primero en el conjunto de los aeropuertos por cada día de la semana. ejecutando el script **delayed_by_day_jan20.awk** directamente sobre el conjunto de datos (**flights_jan_20.csv**)
- Segundo filtrando en el aeropuerto deseado, introduciendo el código identificador como variable al ejecutar el script **airport_delays_by_day_jan20.awk**

En la segunda parte encontramos una serie de scripts que nos ofrecen una descrpción de un conjunto de datos numérico, previa limpieza de los mismos, se muestran gráficas con la distribución de cada uno de los atributos, número de valores nulos, boxplots y matriz de dispersión, mediante gnuplot (archivo **b_part.sh**). También se crea una función one_hot_encoder() para la transformación de datos categóricos si fuera necesario y se eliminan los registros con más de 2 valores nulos para el posterior análisis estadístico de los datos. En el mismo script se ejecuta **c_awk.awk** que imita el comportamiento de funciones sencillas que nos ofrecen muchos lenguajes de programación como describe(), summary()...Obtenemos el número de registros total, el número de registros nulos, la media, la varianza (N, N+1 y N+2), desviación estándar, sumatorio de valores, suma de cuadrados (𝑥􀯜 − 𝑥̅), suma de cuadrados no corregida, desviación media, coeficiente de asimetría, coeficiente de curtosis, valor máximo (y el número de fila en que se encuentra), valor mínimo (y le número de fila), los cuartiles q1, q2 (mediana) y q3 y la moda, en caso de no existir valores repetidos nos lo indica por pantalla, en caso de existir, nos dice el valor y las veces que se repite (tratando de optimizar el número de iteraciones sobre nuestros datos, ya que hay valores que requieren cálculos previos, valores ordenados...).

El script **c_bash.sh** ofrece distintas funciones para el tratamiento de datos nulos (mean_replace(), median_replace(), mode_replace() y value_replace()), para la normalización de datos (min max, normalización estándar) seleccionando la columna concreta que deseamos transformar y accediendo a los cálculos del script anterior, conservando los datos originales. Finalmente se muestra la nueva distribución de los datos por pantalla (gnuplot).

Finalmente, el script **d.sh** ejecuta todos los anteriores y crea un informe en formato html de los datos por clase, guardando cada uno de los gráficos en archivos .png. El script **run.sh** es el encargado de ejecutar todos los scripts y ofrecer los resultados por pantalla, eliminando algunos archivos temporales. 

Podemos ver una explicación más detallada en el archivo **pdf/imaseda_PRAC.pdf**.

Esta práctica se ha realizado bajo el contexto de la asignatura _Programación en scripting_, perteneciente al Máster en Ciencia de Datos de la Universitat Oberta de Catalunya.

## Autor

La actividad ha sido realizada por **Iván Maseda Zurdo**.
