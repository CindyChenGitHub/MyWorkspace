USE [DBA_Config_DB]
GO
/****** Object:  StoredProcedure [dbo].[usp_Backup_Restore_Single_DB]    Script Date: 8/27/2021 11:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- Run example1: usp_Backup_Restore_Single_DB '0243Testing1', '0243Testing7'
-- Run example2: usp_Backup_Restore_Single_DB '0243Testing1', '0243Testing7',  , 1, 1
-- Run example3: usp_Backup_Restore_Single_DB '0243Testing1', '0243Testing7', @exectType = 1, @overwrite = 1, @kill = 1, @stopat = '2021-07-05 09:00'
ALTER PROCEDURE [dbo].[usp_Backup_Restore_Single_DB] 
	-- Add the parameters for the stored procedure here
	@srcDB VARCHAR(50)
	, @targetDB VARCHAR(50)
	, @exectType int = 0 -- 0: print SQL; 1: exect
	, @overwrite int = 0
	, @kill int = 0
	, @stopat VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Declaration
	DECLARE @msg NVARCHAR(50) 
	DECLARE @sql varchar(1000)
	DECLARE @srcDbExsit int = 0
	DECLARE @backupExsit int = 0
	DECLARE @targetDbExsit int = 0
	DECLARE @targetDataExsit int = 0
	DECLARE @targetLogExsit int = 0

	-- Default backup path
	DECLARE @bkupPath VARCHAR(500)
	DECLARE @srcDataPath Varchar(100), @srcLogPath Varchar(100)
	DECLARE @targetDataPath VARCHAR(500), @targetLogPath VARCHAR(500)
	/* -- The following statement works only on version 2019 and up
	SET @bkupPath = (select CONVERT(VARCHAR,SERVERPROPERTY('instancedefaultbackuppath'))) + '\' + @srcDB + '.bak'
	-- For version before 2019, use the xp_instance_regread (following stmt)
	*/
	DROP Table IF EXISTS #backuppath
	CREATE Table #backuppath (item VARCHAR(50), bkpath VARCHAR(500))
	INSERT INTO #backuppath
		EXECUTE [master].dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', 
				N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory'
	SET @bkupPath = (select bkpath FROM #backuppath) + '\' + @srcDB + '.bak'

	-- print @bkupPath
	-- print @targetDataPath
	-- print @targetLogPath

	-- Check db exsit
	--IF (SELECT count(*) FROM master..sysdatabases WHERE name = @srcDB) = 0 
	--	BEGIN
	--		SET @srcDbExsit = 0
	--		SET @msg = '--Statu 1. Fail: Database [' + @srcDB + '] not found';
	--		RAISERROR (@msg, 1, -1) WITH NOWAIT;
	--		return
	--	END
	--ELSE
		-- SET @srcDbExsit = 1

	
	-- Check src DB or backup exsit
	SET @srcDbExsit = (SELECT count(*) FROM master..sysdatabases WHERE name = @srcDB)
	EXEC master.dbo.xp_fileexist @bkupPath, @backupExsit OUTPUT
	
	IF @srcDbExsit = 0 AND @backupExsit = 0
		BEGIN
			SET @msg = '--Statu 1. Fail: Database [' + @srcDB + '] not found';
			RAISERROR (@msg, 1, -1) WITH NOWAIT;
			return
		END
	-- Backup if DB exsit and backup not exsit
	IF @srcDbExsit <> 0 AND @backupExsit = 0
		BEGIN
			SET @sql = 'BACKUP DATABASE ' + @srcDB  + ' TO DISK=''' + @bkupPath + '''
    WITH COMPRESSION'
			--IF @backupExsit <> 0
			--	SET @sql = @sql + ' WITH INIT'
			IF @exectType = 0
				print  (@sql)
			ELSE
			    exec (@sql)
		END
		

	-- Get target Database logicalNames



	drop Table if exists #filelist
	create table #filelist (LogicalName VARCHAR(100), v2 varchar(100), [Type] varchar(10),v4 varchar(100),v5 varchar(100), v6 varchar(100),
						v7 int, v8 int, v9 int, v10 varchar(100),v11 int, v12 int, v13 int, v14 int, v15 int, v16 varchar(100),
						v17 varchar(100),v18 varchar(100), v19 int, v20 int, v21 varchar(100),v22 varchar(100))

	-- Check target DB/mdf/ldf exsit
	SET @targetDataPath = (select CONVERT(VARCHAR,SERVERPROPERTY('instancedefaultdatapath'))) +  @targetDB + '.mdf'
	SET @targetLogPath = (select CONVERT(VARCHAR,SERVERPROPERTY('instancedefaultlogpath'))) +  @targetDB + '_log.ldf'
	
	SET @targetDbExsit = (SELECT count(*) FROM master..sysdatabases WHERE name = @targetDB)
	EXEC master.dbo.xp_fileexist @targetDataPath, @targetDataExsit OUTPUT
	EXEC master.dbo.xp_fileexist @targetLogPath, @targetLogExsit OUTPUT

	-- Get src mdf/ldf path
			set @sql = 'RESTORE FILELISTONLY FROM Disk = ''' + @bkupPath + '''' 
			insert into #filelist exec (@sql)
			Set @srcDataPath = (select LogicalName from #filelist where [Type] = 'D')
			Set @srcLogPath = (select LogicalName from #filelist where [Type] = 'L')

	-- Set SQL query	
	IF @exectType = 1
		begin

		end
	ELSE
		begin
			Set @srcDataPath = (
				select name from sys.master_files 
				where type_desc = 'ROWS' 
				and database_id = (
					select database_id 
					from sys.databases 
					where name = @srcDB
					)
				)
			Set @srcLogPath = (
				select name from sys.master_files 
				where type_desc = 'LOG' 
				and database_id = (
					select database_id 
					from sys.databases 
					where name = @srcDB
					)
				)
		END
	Set @sql = 'RESTORE DATABASE [' + @targetDB + '] FROM Disk = ''' + @bkupPath + '''
		WITH MOVE ''' + @srcDataPath + ''' TO ''' + @targetDataPath + ''',
			 MOVE ''' + @srcLogPath + ''' TO ''' + @targetLogPath + ''''
	-- print @sql
 
	-- Query for killing the connections
	DECLARE @sqlkill varchar(8000) = '';  
	SELECT @sqlkill = @sqlkill + 'kill ' + CONVERT(varchar(5), session_id) + ';'  
	FROM sys.dm_exec_sessions
	WHERE database_id  = db_id(@targetDB)

	IF (Select count(*) from master..sysdatabases where name = @targetDB) = 0 -- @targetDB does not exist => restore
		BEGIN
			print '--Statu 2. Success: database [' + @targetDB + '] be created and restored from [' + @srcDB + ']'
			IF @exectType = 0
				Begin
					if @kill <> 0
						print @sqlkill
					print @sql
				End
			ELSE
				Begin
					if @kill <> 0
						exec (@sqlkill)
					exec (@sql)
				End
			--END
		END
	ELSE					-- @targetDB exists
		BEGIN
		IF @overwrite = 0
			print '--Statu 3. Fail: database [' + @targetDB + '] exists. Restoration is not performed due to no overwrite permitted.' -- if exist, no restore (no overwrite)
		ELSE
			BEGIN
				IF (select count(*) from master..sysprocesses where @targetDB = db_name(dbid)) > 0 AND @kill = 0
					print '--Statu 4. Fail: database [' + @targetDB + '] is currently in use. Restoration is not performed due to no kill.'
				ELSE
					BEGIN
					IF (select count(*) from master..sysprocesses where @targetDB = db_name(dbid)) = 0
						print '--Statu 5. Success: database [' + @targetDB + '] exists but not currently in use. Restore with replace.'
					IF (select count(*) from master..sysprocesses where @targetDB = db_name(dbid)) > 0 AND @kill <> 0
						BEGIN
							print '--Statu 6. Success: database [' + @targetDB + '] is currently in use. Kill the connection. Restore with replace.'
							IF @exectType = 0
								print @sqlkill
							ELSE
								Exec (@sqlkill)
						END

					--print '6. Restore with replace.'
					SET @sql = @sql + char(13) + char(10) + '		,REPLACE'
					IF @stopat IS NOT NULL
						SET @sql = @sql + ', STOPAT = ''' + @stopat + ''''
						IF @exectType = 0
							print @sql
						ELSE
							Exec @sql
					END
			END
		END
	SET NOCOUNT OFF
END
