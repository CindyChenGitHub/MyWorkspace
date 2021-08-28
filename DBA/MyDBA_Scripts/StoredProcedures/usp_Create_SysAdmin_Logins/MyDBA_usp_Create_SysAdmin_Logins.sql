-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Create_SysAdmin_Logins] 
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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
    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
END
GO
