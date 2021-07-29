------------------------------------------------------------
-- Restore Database from .bak files
------------------------------------------------------------
--## Restore [Orders]
RESTORE DATABASE [0179Orders] FROM DISK='G:\G2SQLBackup\Orders.bak'
WITH MOVE 'Orders' TO 'E:\G2SQLData\PROD\0179Orders_Data.mdf',
     MOVE 'Orders_log' TO 'F:\G2SQLLog\PROD\0179Orders_Log.ldf'
     --, REPLACE
--## Restore [Products]
RESTORE DATABASE [0179Products] FROM DISK='G:\G2SQLBackup\Products.bak'
WITH MOVE 'Products_dat' TO 'E:\G2SQLData\PROD\0179Products_Data.mdf',
     MOVE 'Products_log' TO 'F:\G2SQLLog\PROD\0179Products_Log.ldf'
     --, REPLACE
--## Restore [AdventureWorks]
RESTORE DATABASE [0179AdventureWorks] FROM DISK='G:\G2SQLBackup\AdventureWorks.bak'
WITH MOVE 'AdventureWorks' TO 'E:\G2SQLData\PROD\0179AdventureWorks_Data.mdf',
     MOVE 'AdventureWorks_log' TO 'F:\G2SQLLog\PROD\0179AdventureWorks_Log.ldf'
     --, REPLACE
------------------------------------------------------------
-- Restore Database from .mdf/ .ldf files
------------------------------------------------------------
--## Restore [Orders]
EXEC sp_attach_db @dbname = N'0179Orders',
@0179Orders_Data.mdf = N'E:\G2SQLData\PROD\0179Orders_Data.mdf',
@0179Orders_Data.ldf = N'F:\G2SQLData\PROD\0179Orders_Data.ldf'
------------------------------------------------------------
-- Create Database
------------------------------------------------------------
CREATE DATABASE 0179Orders 
    ON (FILENAME = 'E:\G2SQLData\PROD\0179Orders_Data.mdf'), 
    (FILENAME = 'F:\G2SQLData\PROD\0179Orders_Data.ldf') 
    FOR ATTACH; 