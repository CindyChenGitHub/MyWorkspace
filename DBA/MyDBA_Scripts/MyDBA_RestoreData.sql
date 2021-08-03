------------------------------------------------------------
-- Display database info (include logic files)
------------------------------------------------------------
EXEC sp_helpdb
EXEC sp_helpdb Orders

--## display current owner
SELECT name, sid [Current owner ID], suser_sname(sid) [Current owner name]
FROM sysdatabases
------------------------------------------------------------
-- Simple Create Database
------------------------------------------------------------
-- auto create .mdf in Data folder and .ldf in Log folder as setup when pos-config
CREATE DATABASE Testing1
------------------------------------------------------------
-- Create Database from .mdf .ldf
------------------------------------------------------------
--Create Database from 
CREATE DATABASE 0179Orders 
    ON (FILENAME = 'E:\G2SQLData\PROD\0179Orders_Data.mdf'), 
    (FILENAME = 'F:\G2SQLData\PROD\0179Orders_Data.ldf') 
    FOR ATTACH; 
------------------------------------------------------------
-- Backup Database to .bak files
------------------------------------------------------------
-- Initial (Full) backup for database mirroring
BACKUP DATABASE AdventureWorks TO
    DISK='F:\SQLBackup\AW_Full.BAK'
-- Backup T-Log for initialize of mirroring
BACKUP LOG AdventureWorks TO
    DISK='F:\SQLBackup\AW_TLog.TRN'
------------------------------------------------------------
-- Check logic file info from .bak
------------------------------------------------------------
-- Verify the backup file is good and readable, not really restore
RESTORE VERIFYONLY FROM DISK= 'E:\SQLBackup\Testing1.BAK' 
-- View the backup file.
RESTORE HEADERONLY FROM DISK= 'E:\SQLBackup\Testing1.BAK'
-- List files in the backup file.
RESTORE FILELISTONLY FROM DISK= 'E:\SQLBackup\Testing1.BAK'
-- List files label in the backup file.
RESTORE LABELONLY FROM DISK='G:\G2SQLBackup\Orders.bak'
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
WITH MOVE 'AdventureWorks_Data' TO 'E:\G2SQLData\PROD\0179AdventureWorks_Data.mdf',
     MOVE 'AdventureWorks_log' TO 'F:\G2SQLLog\PROD\0179AdventureWorks_Log.ldf'
     --, REPLACE
------------------------------------------------------------
-- Create Database attach from .mdf .ldf
------------------------------------------------------------
CREATE DATABASE Testing7 
    ON (FILENAME = 'C:\SQLDataBase\PROD\SQLData\Testing1.mdf')
	--,(FILENAME = 'C:\SQLDataBase\PROD\SQLLog\Testing1_log.ldf') 
    FOR ATTACH;
