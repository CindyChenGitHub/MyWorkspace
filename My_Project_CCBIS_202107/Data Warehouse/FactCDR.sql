USE [CCBISDW]
GO

/****** Object:  Table [dbo].[CDR]    Script Date: 7/10/2021 11:55:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FactCDR](
	[CDRID] [int] NOT NULL,
	[CustomerKey] [int] NULL,
	[AgentKey] [int] NULL,
	[CallDate] [date] NULL,
	[Start_TM] [datetime] NULL,
	[End_TM] [datetime] NULL,
	[Status] [varchar](255) NULL,
	[Satisfaction] [int] NULL,
	[FirstResolved] [int] NULL,
	[HandleType_Key] [int] NULL,
	[ServiceType_Key] [int] NULL,
	[SeverityType_Key] [int] NULL,
	[CallReason_Key] [int] NULL,
	[NPS] [int] NULL,
	[ProductKey] [int] NULL,
	[CustomerTier] [varchar](255) NULL,
	[CustomerSegment] [varchar](255) NULL,
	[CloseDate] [date] NULL,
 CONSTRAINT [PK__CDR__CRDID] PRIMARY KEY CLUSTERED 
(
	[CDRID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CDR]  WITH CHECK ADD  CONSTRAINT [FK_CDR_AgentKey] FOREIGN KEY([AgentKey])
REFERENCES [dbo].[DimAgent] ([AgentID])
GO

ALTER TABLE [dbo].[CDR] CHECK CONSTRAINT [FK_CDR_AgentKey]
GO

