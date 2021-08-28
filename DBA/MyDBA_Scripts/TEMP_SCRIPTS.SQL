-- Detacah table
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'X1_Orders'
GO

-- Attact database
USE [master]
GO
CREATE DATABASE [X1_AdventureWorks] ON 
( FILENAME = N'E:\COOP16DAEV\AdventureWorks_Data.mdf' )
 FOR ATTACH
GO
-- Backup database
BACKUP DATABASE [X1_Products] TO  DISK = N'G:\COOP16DAEV\X1_Products.bak' WITH  COPY_ONLY, NOFORMAT, NOINIT,  NAME = N'X1_Products-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
-- Restore database
USE [master]
RESTORE DATABASE [X2_Orders] FROM  DISK = N'G:\COOP16DAEV\X1_Orders.bak' WITH  FILE = 1,  NOUNLOAD,  STATS = 5

GO



