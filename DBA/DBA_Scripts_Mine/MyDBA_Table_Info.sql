----------------------------------------------------
-- Listing All Databases
----------------------------------------------------
SELECT * FROM sys.databases;
EXEC sp_databases;
----------------------------------------------------
-- Using INFORMATION_SCHEMA to Access Tables Data
----------------------------------------------------
--USE 0179Orders_Org;
-- list of all tables in the selected database
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
    
-- list of all constraints in the selected database
SELECT TABLE_NAME, CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS;

-- join tables and constraints data
SELECT 
    t.TABLE_NAME,
    c.CONSTRAINT_NAME,
    c.CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLES as t
LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS as c ON t.TABLE_NAME = c.TABLE_NAME
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY
    t.TABLE_NAME ASC
    --, c.CONSTRAINT_TYPE DESC;

-- join tables and constraints data
SELECT 
    t.TABLE_NAME,
    SUM(CASE WHEN c.CONSTRAINT_TYPE = 'PRIMARY KEY' THEN 1 ELSE 0 END) AS pk,
    SUM(CASE WHEN c.CONSTRAINT_TYPE = 'UNIQUE' THEN 1 ELSE 0 END) AS uni,
    SUM(CASE WHEN c.CONSTRAINT_TYPE = 'FOREIGN KEY' THEN 1 ELSE 0 END) AS fk
FROM INFORMATION_SCHEMA.TABLES as t
LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS as c ON t.TABLE_NAME = c.TABLE_NAME
WHERE t.TABLE_TYPE = 'BASE TABLE' AND t.TABLE_NAME != 'sysdiagrams'
GROUP BY
    t.TABLE_NAME
ORDER BY
    t.TABLE_NAME ASC;

-- list of all columns in each table
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = ......;