USE [DBA_Config_DB]
GO
/****** Object:  StoredProcedure [dbo].[usp_Get_User_Mapping]    Script Date: 10/4/2021 4:28:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Get_User_Mapping]
AS 
BEGIN

SET NOCOUNT ON

-- Existing logins
Drop Table If Exists #logins
Create Table #logins (ID Int Identity, [account] Varchar(200), [type] Varchar(10),	
					  privilege Varchar(20), [mapped] Varchar(2000), [perm path] Varchar(200))
Insert Into #logins	Exec xp_logininfo
Delete From #logins 
	Where account LIKE 'Builtin%' OR  account LIKE '%AUTHORITY%'
		OR account LIKE '%SQLAgent%' OR  account LIKE '%SQLWriter%'
		OR account LIKE '%Winmgmt%' OR account LIKE '%SQLTELEMETRY%'
--Select * From #logins

-- List of Databases
Drop Table If Exists #databases
Create Table #databases (ID Int Identity, db VARCHAR(100))
INSERT INTO #databases
	SELECT db = name
	FROM sys.databases 
	WHERE database_id > 4 AND [state] = 0
-- Select * from #databases

-- Table for results
Drop Table If Exists UserMapping
Create Table UserMapping (ID Int Identity, DBname VARCHAR(100), [User] VARCHAR(200), 
			Schemaname VARCHAR(100), DBrole Varchar(200))

-- Each Login
DECLARE @sql nvarchar(max) = N''
DECLARE csr_login CURSOR FOR
	Select ID, account From #logins

DECLARE @ID Int, @login VARCHAR(200)
OPEN csr_login
FETCH NEXT FROM csr_login INTO @ID, @login
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Each database
	DECLARE csr_db CURSOR FOR
		Select db From #databases Order By ID
	DECLARE @db VARCHAR(100)
	OPEN csr_db
	FETCH NEXT FROM csr_db INTO @db
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @sql = N'SELECT N''' + REPLACE(@db,'''','''''') + ''',
			p.name, p.default_schema_name, 
			STUFF((SELECT N'','' + r.name 
			  FROM [' + @db+ N'].sys.database_principals AS r
			  INNER JOIN [' + @db + N'].sys.database_role_members AS rm
			  ON r.principal_id = rm.role_principal_id
			  WHERE rm.member_principal_id = p.principal_id
			  FOR XML PATH, TYPE).value(N''.[1]'',''nvarchar(max)''),1,1,N'''')
			FROM sys.server_principals AS sp
			LEFT OUTER JOIN [' + @db + '].sys.database_principals AS p
			ON sp.sid = p.sid
			WHERE sp.name = @login '

		INSERT INTO UserMapping (DBname, [User], Schemaname, [DBrole])
			EXEC master.sys.sp_executesql @sql, N'@login sysname', @login

		FETCH NEXT FROM csr_db INTO @db
	END
	CLOSE csr_db
	DEALLOCATE csr_db

	FETCH NEXT FROM csr_login INTO @ID, @login
END
CLOSE csr_login
DEALLOCATE csr_login

Delete from UserMapping	WHERE [User] IS NULL
-- select DBname, [User], Schemaname, [DBrole] from UserMapping

SET NOCOUNT OFF
END
