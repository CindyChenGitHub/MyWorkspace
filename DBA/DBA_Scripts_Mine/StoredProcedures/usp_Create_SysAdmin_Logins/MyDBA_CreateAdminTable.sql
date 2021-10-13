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
USE [DBA_Config_DB]
DROP PROCEDURE IF EXISTS MyDBA_CreateAdminTable;
GO
CREATE PROCEDURE MyDBA_CreateAdminTable
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/* Object: Table [dbo].[Coop2106Groups] */
	IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Coop2106Groups]') AND type in (N'U'))
		CREATE TABLE [dbo].[Coop2106Groups](
			[UserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[Access] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[Excel] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[DBF] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[PBI] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[SQLBI] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[DBA] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[Admin] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
		) ON [PRIMARY]
	ALTER AUTHORIZATION ON [dbo].[Coop2106Groups] TO  SCHEMA OWNER 

	/* Object: Table [dbo].[UserMapping] */
	IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserMapping]') AND type in (N'U'))
		CREATE TABLE [dbo].[UserMapping](
			[ID] [int] NULL,
			[DBname] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[User] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[Schemaname] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[DBrole] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
		) ON [PRIMARY]
	ALTER AUTHORIZATION ON [dbo].[UserMapping] TO  SCHEMA OWNER 

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
END
GO