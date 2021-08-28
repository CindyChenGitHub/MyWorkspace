USE [DBA_Config_DB]
GO
/****** Object:  StoredProcedure [dbo].[usp_Backup_Restore_Single_DB]    Script Date: 8/27/2021 12:36:31 AM ******/
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
	@dbsrc VARCHAR(50)
	, @dbdest VARCHAR(50)
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
	DECLARE @dbExsit int = 0
	DECLARE @backupExsit int = 0

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

	-- Check db exsit
	--IF (SELECT count(*) FROM master..sysdatabases WHERE name = @dbsrc) = 0 
	--	BEGIN
	--		SET @dbExsit = 0
	--		SET @msg = '--Statu 1. Fail: Database [' + @dbsrc + '] not found';
	--		RAISERROR (@msg, 1, -1) WITH NOWAIT;
	--		return
	--	END
	--ELSE
		-- SET @dbExsit = 1

	
	-- Check DB or backup exsit
	SET @dbExsit = (SELECT count(*) FROM master..sysdatabases WHERE name = @dbsrc)
	EXEC master.dbo.xp_fileexist @bkuppath, @backupExsit OUTPUT
	
	IF @dbExsit = 0 AND @backupExsit = 0
		BEGIN
			SET @msg = '--Statu 1. Fail: Database [' + @dbsrc + '] not found';
			RAISERROR (@msg, 1, -1) WITH NOWAIT;
			return
		END
	
	IF @dbExsit <> 0 AND @backupExsit = 0
		BEGIN
			SET @sql = 'BACKUP DATABASE ' + @dbsrc  + ' TO DISK=''' + @bkuppath + '''
    WITH COMPRESSION'
			--IF @backupExsit <> 0
			--	SET @sql = @sql + ' WITH INIT'
			IF @exectType = 0
				print  (@sql)
			ELSE
			    exec (@sql)
		END
		

	-- Get Database logicalNames
	Declare @logicaldata Varchar(100), @logicallog Varchar(100)

	drop Table if exists #filelist
	create table #filelist (LogicalName VARCHAR(100), v2 varchar(100), [Type] varchar(10),v4 varchar(100),v5 varchar(100), v6 varchar(100),
						v7 int, v8 int, v9 int, v10 varchar(100),v11 int, v12 int, v13 int, v14 int, v15 int, v16 varchar(100),
						v17 varchar(100),v18 varchar(100), v19 int, v20 int, v21 varchar(100),v22 varchar(100))
	-- Set SQL query	
	IF @exectType = 1
		begin
			set @sql = 'RESTORE FILELISTONLY FROM Disk = ''' + @bkuppath + '''' 
			insert into #filelist exec (@sql)
			Set @logicaldata = (select LogicalName from #filelist where [Type] = 'D')
			Set @logicallog = (select LogicalName from #filelist where [Type] = 'L')
		end
	ELSE
		begin
			Set @logicaldata = (
				select name from sys.master_files 
				where type_desc = 'ROWS' 
				and database_id = (
					select database_id 
					from sys.databases 
					where name = @dbsrc
					)
				)
			Set @logicallog = (
				select name from sys.master_files 
				where type_desc = 'LOG' 
				and database_id = (
					select database_id 
					from sys.databases 
					where name = @dbsrc
					)
				)
		END
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
			print '--Statu 2. Success: database [' + @dbdest + '] be created and restored from [' + @dbsrc + ']'
			IF @exectType = 0
				print @sql
			ELSE
			    exec (@sql)
			--END
		END
	ELSE					-- @dbdest exists
		BEGIN
		IF @overwrite = 0
			print '--Statu 3. Fail: database [' + @dbdest + '] exists. Restoration is not performed due to no overwrite permitted.' -- if exist, no restore (no overwrite)
		ELSE
			BEGIN
				IF (select count(*) from master..sysprocesses where @dbdest = db_name(dbid)) > 0 AND @kill = 0
					print '--Statu 4. Fail: database [' + @dbdest + '] is currently in use. Restoration is not performed due to no kill.'
				ELSE
					BEGIN
					IF (select count(*) from master..sysprocesses where @dbdest = db_name(dbid)) = 0
						print '--Statu 5. Success: database [' + @dbdest + '] exists but not currently in use. Restore with replace.'
					IF (select count(*) from master..sysprocesses where @dbdest = db_name(dbid)) > 0 AND @kill <> 0
						BEGIN
							print '--Statu 6. Success: database [' + @dbdest + '] is currently in use. Kill the connection. Restore with replace.'
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
