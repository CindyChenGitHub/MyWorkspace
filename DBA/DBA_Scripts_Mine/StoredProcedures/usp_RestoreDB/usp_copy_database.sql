IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'DBA_Config_DB')
	CREATE DATABASE DBA_Config_DB
GO
USE DBA_Config_DB
GO
DROP PROCEDURE IF EXISTS usp_copy_database;
GO
/*=============================================================*/
-- Author:		Yue (Yolanda), C.				
-- Create date: 2021-10-05						
-- Description:	To clone a database from a source DB   
/*=============================================================*/
CREATE PROCEDURE usp_copy_database 
	@src_db VARCHAR(20) = ''		-- Source_DB
	,@dest_db VARCHAR(50) = ''		-- dest_db
	,@overwrite VARCHAR(1) = 'N'	-- Overwrite: Y – overwrite, N (default) – not overwrite 
	,@drop_conn VARCHAR(1) = 'N'	-- Dropping the user connected sessions to the DB: Y – drop, N (default) – not drop
AS
BEGIN
	DECLARE @exectMode VARCHAR(1) = 'N'		-- 'Y': Execute mode; 'N': Display SQL query mode (for debug)
	Declare @tempString VARCHAR(200)
	Declare @sqlQuery VARCHAR(200)
	DECLARE @msg NVARCHAR (200)
	DECLARE @needClear VARCHAR(1) = 'N' 	-- 'Y': Need clear the bak file; 'N': Doesn't clear the bak file.
	DECLARE @actionCounter INT = 0
	declare @src_db VARCHAR(10) = 'Testing1' -- for debug
	declare @dest_db VARCHAR(10) = 't2 , t5 ,, t+' -- for debug
	declare @overwrite VARCHAR(1) = 'N' -- for debug
	declare @drop_conn VARCHAR(1) = 'N' -- for debug
	/*=============================================================*/
	-- 1. Check Source DB Exsit 
	/*=============================================================*/
	DECLARE @src_db_Exsit INT, @src_bak_Exsit INT, @src_Data_Exsit INT
	DECLARE @defaultDataDir nvarchar(256), @defaultLogDir nvarchar(256), @defaultBakDir nvarchar(256)
	DECLARE @srcDataFile nvarchar(256), @srcLogFile nvarchar(256), @srcBakFile nvarchar(256)
	-- Get Instance Default data file, log file, backup file Directories 
	/*
	-- The following statement works only on version 2019 and up
	SET @bkuppath = (select CONVERT(VARCHAR,SERVERPROPERTY('instancedefaultbackuppath'))) + '\' + @dbsrc + '.bak'
	-- For version before 2019, use the xp_instance_regread (following stmt)
	*/
	EXECUTE [master].dbo.xp_instance_regread
		N'HKEY_LOCAL_MACHINE', 
		N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer',
		N'BackupDirectory',
		@defaultBakDir OUTPUT
	SET @defaultDataDir = (select CONVERT(VARCHAR,SERVERPROPERTY('instancedefaultdatapath')))
	SET @defaultLogDir = (select CONVERT(VARCHAR,SERVERPROPERTY('instancedefaultlogpath')))
	print (@defaultBakDir + ', ' + @defaultDataDir + ', ' + @defaultLogDir)  -- for debug
	-- Check source DB exsit
	SET @src_db_Exsit = (SELECT count(*) FROM master..sysdatabases WHERE name = @src_db)
	-- Check bakup file exsit
	SET @srcBakFile = CONCAT (RTRIM(LTRIM(@defaultBakDir)), '\', RTRIM(LTRIM(@src_db)), '.bak')
	EXEC master.dbo.xp_fileexist @srcBakFile, @src_bak_Exsit OUTPUT
	-- Check mdf file exsit
	SET @srcDataFile = CONCAT (RTRIM(LTRIM(@defaultDataDir)), '\', RTRIM(LTRIM(@src_db)), '.mdf')
	EXEC master.dbo.xp_fileexist @srcDataFile, @src_Data_Exsit OUTPUT
	print (convert(varchar, @src_db_Exsit) + ', ' + convert(varchar, @src_bak_Exsit) + ', ' + convert(varchar, @src_Data_Exsit)) -- for debug
	print (@srcBakFile + ', ' + @srcDataFile) -- for debug
	-- Exit when not exsit
	IF @src_db_Exsit = 0 AND @src_bak_Exsit = 0 AND @src_Data_Exsit = 0
		BEGIN
			SET @msg = '--Statu 1. Fail: Database [' + @src_db + '] not found';
			RAISERROR (@msg, 1, -1) WITH NOWAIT;
			RETURN
		END
	-- Create DB when only have mdf file
	IF @src_db_Exsit = 0 AND @src_bak_Exsit = 0 AND @src_Data_Exsit <> 0
		BEGIN
			SET @sqlQuery = 'CREATE DATABASE ' + @src_db + ' ON (FILENAME = ''' + @srcDataFile + ''')'
			IF @exectMode = 'N'
				PRINT  (@sqlQuery)
			ELSE
			    EXEC (@sqlQuery)
		END
	/*=============================================================*/
	-- 2. Check destination database list 
	/*=============================================================*/
	-- Create destination list
	DROP TABLE IF EXISTS #dest_db_List
	CREATE TABLE #dest_db_List
	(
		dest_db VARCHAR(10)
	)
	INSERT INTO #dest_db_List (dest_db)
		SELECT RTRIM(LTRIM(value)) FROM string_split(@dest_db, ',') WHERE value <> ''
	SELECT * FROM #dest_db_List -- For debug
	-- Exit if destination missing
	IF (SELECT COUNT(*) FROM #dest_db_List) = 0
		BEGIN
			SET @msg = '--Statu 2. Fail: Destination database name is empty.';
			RAISERROR (@msg, 1, -1) WITH NOWAIT;
			RETURN
		END
	/*=============================================================*/
	-- 3. Backup (overwrite) Source DB
	/*=============================================================*/
	IF @src_db_Exsit <> 0 OR (@src_db_Exsit = 0 AND @src_bak_Exsit = 0)
		BEGIN
			SET @sqlQuery = 'BACKUP DATABASE ' + @src_db  + ' TO DISK=''' + @defaultBakDir + '\' + @src_db + '.bak' + ''' WITH COMPRESSION'
			IF @src_bak_Exsit <> 0
				BEGIN
					SET @sqlQuery = @sqlQuery + ' WITH INIT'
					SET @needClear = 'Y'
				END
			IF @exectMode = 'N'
				PRINT  (@sqlQuery)
			ELSE
			    EXEC (@sqlQuery)
		END
	/*=============================================================*/
	-- 4. Get source data logic file, log logic file info
	/*=============================================================*/
	declare @defaultBakDir varchar(125)  -- for debug
	declare @sqlQuery VARCHAR(100)-- for debug
	EXECUTE [master].dbo.xp_instance_regread -- for debug
		N'HKEY_LOCAL_MACHINE', -- for debug
		N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer',-- for debug
		N'BackupDirectory',-- for debug
		@defaultBakDir OUTPUT-- for debug
	--print @defaultBakDir -- for debug
	declare @srcBakFile varchar(125)  = @defaultBakDir + '\' + 'UserDB\Testing1\Testing1.bak'  -- for debug
	print @srcBakFile -- for debug
	SET @sqlQuery = 'RESTORE FILELISTONLY FROM DISK = ''' + @srcBakFile + ''''
	print @sqlQuery -- for debug
	drop Table if exists #tempTable
	create table #tempTable (LogicalName VARCHAR(100), v2 varchar(100), [Type] varchar(10),v4 varchar(100),v5 varchar(100), v6 varchar(100),
					v7 int, v8 int, v9 int, v10 varchar(100),v11 int, v12 int, v13 int, v14 int, v15 int, v16 varchar(100),
					v17 varchar(100),v18 varchar(100), v19 int, v20 int, v21 varchar(100),v22 varchar(100))
	insert into #tempTable EXEC (@sqlQuery)
	--SELECT * FROM #tempTable -- for debug
	DECLARE @srcDataName nvarchar(256) 
	DECLARE @srcLogName nvarchar(256)
	Set @srcDataName = (select LogicalName from #tempTable where [Type] = 'D')
	Set @srcLogName = (select LogicalName from #tempTable where [Type] = 'L')
	drop Table if exists #tempTable
	print(@srcDataName + ', ' + @srcLogName) -- for debug
	/*=============================================================*/
	-- 5. SQL query
	/*=============================================================*/
	DECLARE @defaultDataDir nvarchar(256)  -- for debug
	DECLARE @defaultLogDir nvarchar(256)   -- for debug
	DECLARE @destDataFile nvarchar(256)
	DECLARE @destLogFile nvarchar(256)
	DECLARE @cur_dest_db varchar (10)
	-- Set Distination logic data file and logic log file names
	Declare cur_Dest_Cursor Cursor For
		SELECT dest_db FROM #dest_db_List
	OPEN cur_Dest_Cursor
	FETCH NEXT FROM cur_Dest_Cursor INTO @cur_dest_db
	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @destDataFile = @defaultDataDir +  @cur_dest_db + '.mdf'
			SET @destLogFile = @defaultLogDir +  @cur_dest_db + '_log.ldf'
			-- Set SQL query
			SET @sqlQuery = 'RESTORE DATABASE [' + @src_db + '] FROM Disk = ''' + @srcBakFile + '''
				WITH MOVE ''' + @srcDataName + ''' TO ''' + @destDataFile + ''',
					MOVE ''' + @srcLogName + ''' TO ''' + @destLogFile + ''''
	/*=============================================================*/
	-- 6. Drop the connection sessions
	/*=============================================================*/
			IF @drop_conn = 'Y'
			BEGIN 
				DECLARE @sqlkill varchar(8000) = '';  
				-- Drop the connection sessions on destination database
				SELECT @sqlkill = @sqlkill + 'kill ' + CONVERT(varchar(5), session_id) + ';'  
					FROM sys.dm_exec_sessions
					WHERE database_id  = db_id(@cur_dest_db)
				IF @exectMode = 'N'
					print @sql
				ELSE
					exec (@sql)
				-- Drop the connection sessions on destination database
			END




			print ('Copied database from: ' + @src_db + ' to: ' + @cur_dest_db)
			SET @actionCounter = @actionCounter + 1
			FETCH NEXT FROM cur_Dest_Cursor INTO @cur_dest_db
		END
	/***** End: Cleaning *****/
	PRINT ('Statu . Database copy completed successfully. ' + convert(varchar, @actionCounter) + ' database restored.')
	SET @needClear = 'N'
	SET @actionCounter = 0
	CLOSE cur_Dest_Cursor
	DEALLOCATE cur_Dest_Cursor
	CLOSE #dest_db_List
	DROP TABLE #dest_db_List
/*==============================================*/
--Examples to test:
/*==============================================*/
