USE [DBA_Config_DB]
GO
/****** Object:  Table [dbo].[Coop2106Groups]    Script Date: 8/24/2021 5:15:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Coop2106Groups]') AND type in (N'U'))
BEGIN
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
END
GO
ALTER AUTHORIZATION ON [dbo].[Coop2106Groups] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[UserMapping]    Script Date: 8/24/2021 5:15:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserMapping]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[UserMapping](
	[ID] [int] NULL,
	[DBname] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Schemaname] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DBrole] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
ALTER AUTHORIZATION ON [dbo].[UserMapping] TO  SCHEMA OWNER 
GO