USE [DBA_Config_DB]
GO
/****** Object:  StoredProcedure [dbo].[usp_Create_Public_Logins]    Script Date: 10/4/2021 4:27:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Proc [dbo].[usp_Create_Public_Logins]
@class Varchar(20) = 'DBF', @database Varchar(500) = 'Orders, Products, AdventureWorks'
AS
Begin
	Set NOCOUNT ON
	-- Declare @class Varchar(20) = 'PBI', @database Varchar(500) = 'Orders, Products, AdventureWorks'
	IF @class = '' OR @class IS NULL 
		Set @class = 'DBF'
	IF @database  = '' OR @database IS NULL 
		Set @database = 'Orders, Products, AdventureWorks'

	-- Team and members table (Exclude DBA&BI Admin members)
	Declare @sqltm Varchar(500)
	Set @sqltm = 'Select UserID, ' + @class + ' From Coop2106Groups 
		Where ' + @class + ' IS NOT NULL AND Admin IS NULL'
	-- print @sqltm

	Drop Table If Exists #team
	Create Table #team (ID Int Identity, userID Varchar(50), team Varchar(10))
	Insert Into #team (userID, team)
		Exec (@sqltm)
	-- Select * From #team

	-- Teams, members, databases 
	-- Declare @class Varchar(20) = 'SQLBI', @database Varchar(500) = 'Orders, Products, AdventureWorks'
	Drop Table If Exists #dbroots
	Create Table #dbroots (ID Int Identity, userdb Varchar(50))

	Declare crs_dbroot CURSOR FOR
		Select ltrim(rtrim(value)) db From string_split(@database, ',')
	Open crs_dbroot
	Declare @dbroot Varchar(50)
	Fetch NEXT FROM crs_dbroot INTO @dbroot
	While @@FETCH_STATUS = 0
	Begin
		Insert Into #dbroots (userdb)
			Select Distinct substring(name,charindex('_',name)+1,len(name)-charindex('_',name)) 
				From sys.databases Where name Like '%' + @dbroot + '%'
		Fetch NEXT FROM crs_dbroot INTO @dbroot
	End
	Close crs_dbroot
	DEALLOCATE crs_dbroot
	select * from #dbroots

	-- Declare @class Varchar(20) = 'SQLBI', @database Varchar(500) = 'Orders, Products, AdventureWorks'
	Drop Table If Exists #dbroleuser
	Create Table #dbroleuser (ID Int Identity, userID Varchar(20), team Varchar(10), userdb Varchar(50))
	Insert Into #dbroleuser (userID, team, userdb)
		Select t3.userID, t3.team, Left(t3.team, 2) + '_' + t1.userdb 
			From #dbroots t1  Cross Join #team t3
				JOIN (Select name From sys.databases) t2 ON Left(t3.team,2) + '_' + t1.userdb = t2.name 
		Order By t3.team
	-- Select * from #dbroleuser

	-- Existing logins
	Drop Table If Exists #logins
	Create Table #logins (ID Int Identity, [account] Varchar(200), [type] Varchar(10),	
						  privilege Varchar(20), [mapped] Varchar(2000), [perm path] Varchar(200))
	Insert Into #logins
		Exec xp_logininfo
	Delete From #logins 
		Where account NOT LIKE '%DA\DaTest%'

	-- Create Logins
	Declare @counter Int = 1
	Declare @user Varchar(100)
	Declare @sql Varchar(max)
	Declare csr_user Cursor For
		Select userID From #team
			Order By ID
	Open csr_user
	Fetch Next From csr_user Into @user
	While @@FETCH_STATUS = 0
	Begin
		-- Create Login
		If (select count(*) From #logins Where account = @user) = 0
		Begin 
			Set @sql = 'Create Login [' + @user + '] From Windows'
			RAISERROR(@sql, 1, 1) WITH NOWAIT
			EXEC (@sql)
			Insert Into #logins (account) Values(@user)
			Set @counter += 1
		End

		If @class = 'DBA'
		BEGIN
			Set @sql = 'Exec master..sp_addsrvrolemember @loginame = N''' + @user + ''', @rolename = N''sysadmin'''
			RAISERROR(@sql, 1, 1) WITH NOWAIT
			EXEC (@sql)
		END

		Fetch Next From csr_user Into @user
	END
	Close csr_user
	Deallocate csr_user
	IF @counter = 1
		print 'All logins already exist. No Logins have been created this time.'
	Set @counter = 1
	
	-- Database-level permissions
	IF @class <> 'DBA' -- DBA members skip this
	BEGIN	
		-- Loop thru groups to create user roles
		Declare @tbl table (username varchar(100)) 
		Declare @userID Varchar(100)
		Declare @userdb Varchar(50)
		Declare @team Varchar(10)
		Declare csr_user_db Cursor For
			Select UserID, team, userdb From #dbroleuser
				Order By ID
		Open csr_user_db
		Fetch Next From csr_user_db Into @userID, @team, @userdb
		While @@FETCH_STATUS = 0
		Begin
		-- Create user for a database
			-- If a user exists in the database, drop the user first
			Set @sql = 'select name from ' + @userdb + '.sys.database_principals Where name = ''' + @userID +''''
			Insert Into @tbl exec (@sql)

			IF (select count(*) from @tbl) > 0
			Begin
				Set @sql = 'Use [' + @userdb + ']' + Char(13)
				Set @sql = @sql + 'Drop User [' + @userID + ']'
				RAISERROR(@sql, 1, 1) WITH NOWAIT
				EXEC (@sql)
			End
			Delete From @tbl

			-- Create the user
			Set @sql = 'Use [' + @userdb + ']' + Char(13)
			Set @sql = @sql + 'Create User [' + @userID + '] From Login [' + @userID + ']'
			RAISERROR(@sql, 1, 1) WITH NOWAIT
			EXEC (@sql)
			Set @counter =+ 1

			-- Alter database role
			-- Create proc_executor role
			Set @sql = 'select name from ' + @userdb + '.sys.database_principals Where name = ''proc_executor'''
			Insert Into @tbl exec (@sql)

			IF (select count(*) from @tbl) = 0
			Begin
				Set @sql = 'Use [' + @userdb + ']' + Char(13)
				Set @sql = @sql + 'Create Role proc_executor' + char(13)
				Set @sql = @sql + 'GRANT EXECUTE TO proc_executor'
				RAISERROR(@sql, 1, 1) WITH NOWAIT
				EXEC (@sql)
			End
			Delete From @tbl

			IF @team LIKE '%(L)'  -- Team lead has db_owner role
			BEGIN
				Set @sql = 'Use [' + @userdb + ']' + Char(13)
				Set @sql = @sql + 'Alter Role [db_owner] Add Member [' + @userID + ']'
				RAISERROR(@sql, 1, 1) WITH NOWAIT
				EXEC (@sql)
				Set @counter =+ 1
			END
			ELSE -- All users have db_ddadmin, db_datareader, db_datawriter, and proc_executor roles
			BEGIN
				Set @sql = 'Use [' + @userdb + ']' + Char(13)
				Set @sql = @sql + 'Alter Role [db_ddladmin] Add Member [' + @userID + ']' + char(13)
				Set @sql = @sql + 'Alter Role [db_datareader] Add Member [' + @userID + ']' + char(13)
				Set @sql = @sql + 'Alter Role [db_datawriter] Add Member [' + @userID + ']' + char(13)
				Set @sql = @sql + 'Alter Role [proc_executor] Add Member [' + @userID + ']'
				RAISERROR(@sql, 1, 1) WITH NOWAIT
				EXEC (@sql)
				Set @counter =+ 1
			END
			Fetch Next From csr_user_db Into  @userID, @team, @userdb
		END
		Close csr_user_db
		Deallocate csr_user_db

		IF @counter = 1
			print 'All users already exsit and have datareader and datawwriter permissions. No database users created this time.'
	END

	Set NOCOUNT OFF
End
