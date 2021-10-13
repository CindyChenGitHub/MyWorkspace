USE [DBA_Config_DB]
GO
/****** Object:  StoredProcedure [dbo].[usp_Backup_Restore_DB]    Script Date: 10/4/2021 4:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_Backup_Restore_DB]
	@dbsrc VARCHAR(50), @dbdest VARCHAR(50), @overwrite int = 0, @kill int = 0, @stopat VARCHAR(50) = NULL
AS
BEGIN
SET NOCOUNT ON
--DECLARE @dbsrc VARCHAR(50) ='0243Testing1', @dbdest VARCHAR(50) ='0243Testing7', @overwrite int = 1, @kill int = 1, @stopat VARCHAR(50) = '2021-07-05 09:00'

DECLARE @msg NVARCHAR(50) 
IF (SELECT count(*) FROM master..sysdatabases WHERE name = @dbsrc) = 0 
	BEGIN
		SET @msg = 'Database [' + @dbsrc + '] not found';
		RAISERROR (@msg, 1, -1) WITH NOWAIT;
		return
	END

-- Default backup path
DECLARE @bkuppath VARCHAR(500), @datapath VARCHAR(500), @logpath VARCHAR(500)
/* -- The following statement works only on version 2019 and up
SET @bkuppath = (select CONVERT(VARCHAR,SERVERPROPERTY('instancedefaultbackuppath'))) + '\' + @dbsrc + '.bak'
-- For version before 2019, use the xp_instance_regread (following stmt)
*/
DROP Table IF EXISTS #backuppath
CREATE Table #backuppath (item VARCHAR(50), bkpath VARCHAR(500))
INSERT INTO #backuppath
	EXECUTE [master].dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', 
			N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory'
SET @bkuppath = (select bkpath FROM #backuppath) + '\' + @dbsrc + '.bak'
SET @datapath = (select CONVERT(VARCHAR,SERVERPROPERTY('instancedefaultdatapath'))) +  @dbdest + '.mdf'
SET @logpath = (select CONVERT(VARCHAR,SERVERPROPERTY('instancedefaultlogpath'))) +  @dbdest + '_log.ldf'
-- print @bkuppath
-- print @datapath
-- print @logpath

Declare @logicaldata Varchar(100), @logicallog Varchar(100)
declare @sql varchar(1000)

-- Database logicalNames
drop Table if exists #filelist
create table #filelist (LogicalName VARCHAR(100), v2 varchar(100), [Type] varchar(10),v4 varchar(100),v5 varchar(100), v6 varchar(100),
						v7 int, v8 int, v9 int, v10 varchar(100),v11 int, v12 int, v13 int, v14 int, v15 int, v16 varchar(100),
						v17 varchar(100),v18 varchar(100), v19 int, v20 int, v21 varchar(100),v22 varchar(100))
set @sql = 'RESTORE FILELISTONLY FROM Disk = ''' + @bkuppath + '''' 
insert into #filelist
exec (@sql)

Set @logicaldata = (select LogicalName from #filelist where [Type] = 'D')
Set @logicallog = (select LogicalName from #filelist where [Type] = 'L')

Set @sql = 'RESTORE DATABASE [' + @dbdest + '] FROM Disk = ''' + @bkuppath + '''
	WITH MOVE ''' + @logicaldata + ''' TO ''' + @datapath + ''',
		 MOVE ''' + @logicallog + ''' TO ''' + @logpath + ''''
-- print @sql
 
-- Query for killing the connections
DECLARE @sqlkill varchar(8000) = '';  
SELECT @sqlkill = @sqlkill + 'kill ' + CONVERT(varchar(5), session_id) + ';'  
FROM sys.dm_exec_sessions
WHERE database_id  = db_id(@dbdest)

IF (Select count(*) from master..sysdatabases where name = @dbdest) = 0 -- @dbdest does not exist => restore
	BEGIN
		print '1. Database [' + @dbdest + '] does not exist. Restore the database.'
		print @sql
		-- exec (@sql)
	END
ELSE					-- @dbdest exists
	BEGIN
	IF @overwrite = 0
		print '2. Database [' + @dbdest + '] exists. Restoration is not performed due to no overwrite permitted.' -- if exist, no restore (no overwrite)
	ELSE
		BEGIN
			IF (select count(*) from master..sysprocesses where @dbdest = db_name(dbid)) > 0 AND @kill = 0
				print '3. database [' + @dbdest + '] is currently in use. Restoration is not performed due to no kill.'
			ELSE
				BEGIN
				IF (select count(*) from master..sysprocesses where @dbdest = db_name(dbid)) = 0
					print '4. database [' + @dbdest + '] exists but not currently in use. '
				IF (select count(*) from master..sysprocesses where @dbdest = db_name(dbid)) > 0 AND @kill <> 0
					BEGIN
						print '5. database [' + @dbdest + '] is currently in use. Kill the connection.'
						print @sqlkill
						--Exec (@sqlkill)
					END

				print '6. Restore with replace.'
				SET @sql = @sql + char(13) + char(10) + '		,REPLACE'
				IF @stopat IS NOT NULL
					SET @sql = @sql + ', STOPAT = ''' + @stopat + ''''
				print @sql
				--Exec @sql
				END
		END
	END
SET NOCOUNT OFF
END
