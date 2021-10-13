USE [DBA_Config_DB]
GO
/****** Object:  StoredProcedure [dbo].[usp_Create_SysAdmin_Logins]    Script Date: 10/4/2021 4:27:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Proc [dbo].[usp_Create_SysAdmin_Logins]
AS
Begin
	Set NOCOUNT ON

-- Existing logins
Drop Table If Exists #logins
Create Table #logins (ID Int Identity, [account] Varchar(200), [type] Varchar(10),	
					  privilege Varchar(20), [mapped] Varchar(2000), [perm path] Varchar(200))
Insert Into #logins
	Exec xp_logininfo
Delete From #logins Where account NOT LIKE '%DA\DaTest%'
-- Select * From #logins

Declare @userID Varchar(200)
Declare @sql Varchar(max) = ''
Declare csr_admin Cursor For
	Select UserID From Coop2106Groups 
	Where [Admin] IS NOT NULL
Open csr_admin
Fetch Next From csr_admin Into @userID
While @@FETCH_STATUS = 0
Begin
	If (select account From #logins Where account = @userID) IS NULL
	Begin 
		Set @sql =  @sql + char(13) + 'Use master;' + char(13)
		Set @sql = @sql + 'Create Login [' + @userID + '] From Windows'
		--RAISERROR(@sql, 1, 1) WITH NOWAIT
		EXEC (@sql)
		Insert Into #logins (account) values(@userID)
	End
	Set @sql = 'Exec master..sp_addsrvrolemember @loginame = N''' + @userID + ''', @rolename = N''sysadmin'''
	--RAISERROR(@sql, 1, 1) WITH NOWAIT
	EXEC (@sql)
	Fetch Next From csr_admin Into @userID
END
Close csr_admin
Deallocate csr_admin

Exec xp_logininfo

Set NOCOUNT OFF
End
