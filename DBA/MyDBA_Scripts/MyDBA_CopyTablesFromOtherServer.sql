-- Drop table if exists
USE DBA_Config_DB -- databaseName
DROP TABLE IF EXISTS [dbo].[Coop2106Groups]
DROP TABLE IF EXISTS [dbo].[UserMapping]
-- Check if server linked
select name from sys.servers
-- Link server if not linked
EXEC sp_addlinkedserver @server = 'DBAPRODSRV02\COOP16PRDG1'
EXEC sp_addlinkedsrvlogin 'DBAPRODSRV02\COOP16PRDG1'
                         ,'false'
                         ,NULL
                         ,'sa'
                         ,'Vic2006'
-- Copy tables from other server
select * into [DBA_Config_DB].[dbo].[Coop2106Groups] from [DBAPRODSRV02\COOP16PRDG1].[DBA_Config_DB].[dbo].[Coop2106Groups]
select * into [DBA_Config_DB].[dbo].[UserMapping] from [DBAPRODSRV02\COOP16PRDG1].[DBA_Config_DB].[dbo].[UserMapping]
-- Drop server links
EXEC sp_dropserver @server = 'DBAPRODSRV02\COOP16PRDG1', @droplogins = 'droplogins'