IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'DBA_Config_DB')
	CREATE DATABASE DBA_Config_DB
GO
USE DBA_Config_DB
GO
DROP PROCEDURE IF EXISTS usp_ServerPostConfigure;
GO
/*==============================================*/
-- Author:		Yue (Yolanda), C.				
-- Create date: 2021-10-05						
-- Description:	To Automate Server Proconfig   
/*==============================================*/
CREATE PROCEDURE usp_ServerPostConfigure 
	@p1 VARCHAR(10) = '',
	@p2 VARCHAR(10) = '',
	@p3 VARCHAR(10) = '',
	@p4 VARCHAR(10) = '',
	@p5 VARCHAR(10) = '',
	@p6 VARCHAR(10) = '',
	@p7 VARCHAR(10) = '',
	@p8 VARCHAR(10) = '',
	@p9 VARCHAR(10) = '',
	@p10 VARCHAR(10) = ''
AS
BEGIN
	Declare @tempString Varchar(200)
	/* Mapping input options */
	DROP Table IF EXISTS #actionList
	CREATE TABLE #actionList
	(
	    ID INT Identity,
		parmVal VARCHAR(10)
	)
	-- SET @tempString = CONCAT_WS(',', @p1, @p2, @p3, @p4, @p5, @p6,  @p7,  @p8,  @p9,  @p10); -- Used in SQL Server 2017 and up
	SET @tempString = CONCAT(@p1, ',', @p2, ',', @p3, ',', @p4, ',', @p5, ',', @p6, ',',  @p7, ',',  @p8, ',',  @p9, ',',  @p10)
	INSERT INTO #actionList (parmVal)
		SELECT * FROM string_split(trim(@tempString), ',')
	--SELECT * FROM #actionList -- For debug

	/* Mapping all config options */
	DROP Table IF EXISTS #allConfigList
	CREATE TABLE #allConfigList
	(
	    config_ID INT Identity,
		config_Name VARCHAR(20),
		config_Item VARCHAR(100)
	)
	INSERT INTO #allConfigList VALUES 
		('Hoc',			'Ad Hoc Distributed Queries'), 
		('compression', 'backup compression default'), 
		('clr',			'clr enabled'), 
		('db mail XPs', 'Database Mail XPs'), 
		('remote',		'remote admin connections'), 
		('cmd shell',	'xp_cmdshell')
	--SELECT * FROM #allConfigList -- For debug
	
	/* To config */
	Declare @actionCounter INT = 0
	Declare @tempCounter1 int 
		= (SELECT COUNT(*) FROM #actionList WHERE (parmVal) = 'ALL' OR parmVal = '0')
	Declare @tempCounter2 int 
		= (SELECT COUNT(*) FROM #actionList WHERE parmVal IS NULL or parmVal = '')
	--PRINT (convert(varchar, @tempCounter1) + ' , ' +  convert(varchar, @tempCounter2)) -- For debug
	IF (@tempCounter1 > 0) OR (@tempCounter2 = 10)
		BEGIN
			DECLARE action_Cursor Cursor For
				SELECT config_Item FROM #allConfigList
			OPEN action_Cursor
		END
	ELSE
		BEGIN
			Declare action_Cursor Cursor For
				SELECT a.config_Item FROM #actionList c
					INNER JOIN #allConfigList a
					ON trim(c.parmVal) = CAST(a.config_ID AS VARCHAR)
			OPEN action_Cursor
		END
	FETCH NEXT FROM action_Cursor INTO @tempString
	WHILE @@FETCH_STATUS = 0
		BEGIN
			--PRINT  @tempString -- For debug
			EXEC  sp_configure @tempString , 1
			SET @actionCounter = @actionCounter + 1
			FETCH NEXT FROM action_Cursor INTO @tempString
		END
	RECONFIGURE
	PRINT (convert(varchar, @actionCounter) + ' configerations completed.')
	/* Clearing temp */
	CLOSE action_Cursor;
	DEALLOCATE action_Cursor;
	DROP Table IF EXISTS #actionList
END
/*==============================================*/
--Examples to test:
/*==============================================*/
--Execute USP_DBA_sp_Configure				-- 6 configerations completed.
--Execute USP_DBA_sp_Configure 0			-- 6 configerations completed.
--Execute USP_DBA_sp_Configure 'all'		-- 6 configerations completed.
--Execute USP_DBA_sp_Configure all		-- Error
--Execute USP_DBA_sp_Configure 1			-- 1 configerations completed.
--Execute USP_DBA_sp_Configure 6			-- 1 configerations completed.
--Execute USP_DBA_sp_Configure 1,3,5		-- 3 configerations completed.
--Execute USP_DBA_sp_Configure '1,3,5'		-- 3 configerations completed.
--Execute USP_DBA_sp_Configure '1,3,5',2,7	-- 4 configerations completed.
--Execute USP_DBA_sp_Configure '0,1,3,5'	-- 6 configerations completed.