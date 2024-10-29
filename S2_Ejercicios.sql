################### NIVEL 1 ##################################

# EJERCICIO 1
# A partir de los documentos adjuntos (estructura_datos y datos_introducir), importa las dos tablas. Muestra las principales características del esquema creado y explica las diferentes tablas y variables que existen. Asegúrate de incluir un diagrama que ilustre la relación entre las distintas tablas y variables.

SELECT * FROM transaction;
SELECT * FROM company;

# EJERCICIO 2 - Utilizando JOIN realizarás las siguientes consultas:
# A) Listado de los países que están haciendo compras.

SELECT DISTINCT country
FROM company
JOIN transaction
ON company.id=transaction.company_id;

# B) Desde cuántos países se realizan las compras.

SELECT count(DISTINCT country) as Total_Paises
FROM company
JOIN transaction
ON company.id=transaction.company_id;

#C) Identifica a la compañía con la mayor media de ventas.

#OPCION 1 ===> CON LIMIT
SELECT company_name, ROUND (avg (amount),2)
FROM company
JOIN transaction
ON company.id=transaction.company_id
WHERE declined =0
GROUP BY company_name
ORDER BY 2 DESC
LIMIT 1;

#OPCION 2 ===> SIN LIMIT
SELECT company_name, ROUND(avg (amount),2) as Max_media_ventas
FROM company
JOIN transaction
ON company.id=transaction.company_id
WHERE declined =0
GROUP BY company_name
HAVING ROUND(avg(amount), 2) = (SELECT ROUND (MAX(Media_ventas),2)
FROM (SELECT avg(amount) as Media_ventas
FROM transaction
WHERE declined =0
GROUP BY company_id) AS AUX);


# EJERCICIO 3 -  Utilizando sólo subconsultas (sin utilizar JOIN):
# A) Muestra todas las transacciones realizadas por empresas de Alemania.

SELECT *, (SELECT country FROM company WHERE id = company_id) as Country
FROM transaction
WHERE company_id IN (SELECT id FROM company WHERE country = 'Germany');

# B) Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.

SELECT DISTINCT company_id, (SELECT company_name FROM company WHERE id = company_id) as Name_CIA,amount 
FROM transaction
WHERE amount > (SELECT avg(amount) FROM transaction)
ORDER BY 3 ASC;

###### CONTROL DE LA MEDIA##########
SELECT ROUND (avg (amount),2) 
FROM transaction;
#La media de las transacciones es 256,74

# C) Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.

#OPCION 1 ==> NOT IN
SELECT company_name
FROM company
WHERE id NOT IN (SELECT company_id FROM transaction);

#OPCION 2 ==> NOT EXISTS
SELECT company_name
FROM company
WHERE NOT exists (SELECT * FROM transaction);



################### NIVEL 2 ##################################
#EJERCICIO 1 - Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. Muestra la fecha de cada transacción junto con el total de las ventas.

SELECT DATE (timestamp) as Dias, sum(amount) AS Total_Ventas
FROM transaction
WHERE declined =0
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

# EJERCICIO 2 -¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio.

SELECT country, ROUND (avg(amount),2) AS Media_Ventas
FROM company
JOIN transaction
ON company.id=transaction.company_id
WHERE declined =0
GROUP BY 1
ORDER BY 2 DESC;

# EJERCICIO 3 - En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía “Non Institute”. Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.

####### CONTROL=> BUSQUEDA DE LA EMPRESA PARA SABER EL PAIS####
SELECT company_name, country
FROM company
WHERE company_name LIKE 'Non Institute';
# PAIS ==> UNITED KINGDOM

# A) Muestra el listado aplicando JOIN y subconsultas.

SELECT *
FROM transaction
JOIN company
ON company.id=transaction.company_id
WHERE country = (SELECT country FROM company
WHERE company_name LIKE 'Non Institute') AND company_name NOT IN ('Non Institute');

#B) Muestra el listado aplicando solo subconsultas.

SELECT *, (SELECT company_name FROM company WHERE id = company_id) as Name_CIA, (SELECT country FROM company WHERE id = company_id) as Pais
FROM transaction
WHERE company_id IN (SELECT id FROM company 
WHERE country = (SELECT country FROM company WHERE company_name LIKE 'Non Institute')
AND company_name NOT IN ('Non Institute'));


################### NIVEL 3 ##################################
# EJERCICIO 1
# Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido entre 100 y 200 euros y en alguna de estas fechas: 29 de abril de 2021, 20 de julio de 2021 y 13 de marzo de 2022. Ordena los resultados de mayor a menor cantidad.

SELECT company_name, phone, country,DATE (timestamp) as Dias, amount
FROM company
JOIN transaction
ON company.id=transaction.company_id
WHERE amount BETWEEN 100 AND 200
AND DATE (timestamp) IN ('2021-04-29','2021-07-20','2022-03-13')
ORDER BY amount DESC; 

#EJERCICIO 2
# Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas, pero el departamento de recursos humanos es exigente y quiere un listado de las empresas donde especifiques si tienen más de 4 o menos transacciones.

SELECT company_id, count(*) as Total_Transacciones,
CASE WHEN count(*) > 4 THEN "Tiene mas de 4 transacciones"
    ELSE "Tiene 4 o menos transacciones"END AS Especificación_RRHH
FROM transaction 
GROUP BY 1;