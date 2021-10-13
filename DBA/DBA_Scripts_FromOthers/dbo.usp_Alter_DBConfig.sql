USE [DBA_Config_DB]
GO
/****** Object:  StoredProcedure [dbo].[usp_Alter_DBConfig]    Script Date: 10/4/2021 4:06:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_Alter_DBConfig]
	@database VARCHAR(50) ='', @action VARCHAR(15) = ''
AS
BEGIN
SET NOCOUNT ON
 --DECLARE @database VARCHAR(max) ='Order%, Prod%, Testing%', @action VARCHAR(15) = ''
 
IF @action = '' OR @action is NULL OR convert(VARCHAR, @action) = '0'
	SET @action = '1, 2, 3'
-- print @action
IF @database is NULL OR @database =''
	SET @database = '*Orders%, %Products%'
-- print @database

-- Parse @database for database names
DROP TABLE IF EXISTS #dbin 
CREATE Table #dbin (ID INT IDENTITY, [db] VARCHAR(50),[dbname] VARCHAR(50))
INSERT INTO #dbin (db)
	SELECT * FROM string_split(@database,',')
UPDATE #dbin set [db] = ltrim(rtrim([db])),
				 [dbname] = replace(ltrim(rtrim([db])), '*','%')
-- select * from #dbin

-- Database list
DROP TABLE IF EXISTS #database 
CREATE Table #database (ID INT IDENTITY, [servername] VARCHAR(100), [dbname] VARCHAR(50), 
	[owner] VARCHAR(50), mode VARCHAR(10), rec2mode VARCHAR(10), 
	sqlversion VARCHAR(5), dbversion VARCHAR(5))
INSERT INTO #database (servername, dbname, [Owner], mode, dbversion)
	SELECT @@SERVERNAME, name, SUSER_SNAME(owner_sid), 
			recovery_model_desc, compatibility_level
		FROM sys.databases s JOIN #dbin t
		-- ON s.name like '%' + t.dbname + '%'
		ON s.name like t.dbname
UPDATE #database 
	SET [sqlversion] =
			(SELECT TOP 1 compatibility_level FROM sys.databases
				WHERE name = 'master'),
		[rec2mode] =
			CASE WHEN servername LIKE '%PROD%' OR servername LIKE '%DR%' 
						OR servername LIKE '%PRD%' THEN 'FULL'
				 ELSE 'SIMPLE'
				 END
-- Select * from #database

-- Parse strings for actions
DROP TABLE IF EXISTS #action 
CREATE Table #action (ID INT IDENTITY, action_code VARCHAR(2), [action] VARCHAR(50))
INSERT INTO #action ([action_code])
	SELECT * FROM string_split(@action,',')
UPDATE #action 
	SET [action_code] = ltrim(rtrim([action_code])),
		[action] = 
			CASE WHEN [action_code] = '1' THEN 'Handle Recovery Mode'
				 WHEN [action_code] = '2' THEN 'Change db_owner'
				 ELSE 'Sync SQL Version'
				 END
-- select * from #action

-- Action and query for each database
DROP TABLE IF EXISTS #db_action 
CREATE Table #db_action (ID INT IDENTITY, dbname VARCHAR(50), [owner] VARCHAR(50), 
	mode VARCHAR(10), rec2mode VARCHAR(10), sqlversion VARCHAR(5), dbversion VARCHAR(5), 
	action_code VARCHAR(2), [action] VARCHAR(50), [Query] VARCHAR(200))
INSERT INTO #db_action (dbname, [owner], mode, rec2mode, sqlversion, dbversion, 
						action_code, [action])
	SELECT d.dbname, d.[owner], d.mode, d.rec2mode, d.sqlversion, d.dbversion, 
		   a.action_code, a.[action] 
		FROM #database d, #action a
UPDATE #db_action SET [Query] = 
	CASE WHEN [action_code] = '1' THEN
			  'ALTER DATABASE [' + dbname + '] SET RECOVERY ' + rec2mode
		 WHEN [action_code] = '2' AND [owner] <> 'sa' THEN 
			  '[' + dbname + ']..sp_changedbowner ''sa'''
		 WHEN [action_code] = '3' AND dbversion <> sqlversion THEN
			  'ALTER DATABASE [' + dbname + '] SET compatibility_level = ' + sqlversion
		 ELSE NULL END
-- select * from #db_action

DECLARE @ID INT
DECLARE @qry VARCHAR(200)
DECLARE csr_dbact CURSOR FOR
	SELECT ID, Query FROM #db_action
		WHERE Query IS NOT NULL

OPEN csr_dbact
FETCH NEXT FROM csr_dbact INTO @ID, @qry
WHILE @@FETCH_STATUS = 0
BEGIN
	-- print @qry
	exec (@qry)
	FETCH NEXT FROM csr_dbact INTO @ID, @qry
END
CLOSE csr_dbact
DEALLOCATE csr_dbact

SET NOCOUNT OFF
END
