USE CCBIS
INSERT INTO [dbo].[DimAgent](FirstName, LastName, [Group], [Location]) values ('Jarrod', 'Todd', 'Level 1', 'London')
UPDATE [CCBIS].[dbo].[CDR] SET NPS=12 WHERE CDRID=1
UPDATE [CCBIS].[dbo].[CDR] SET Satisfaction=7 WHERE CDRID=3
UPDATE [CCBIS].[dbo].[DimCustomer] SET LastName=null WHERE CustomerKey=11002

INSERT INTO [dbo].[CDR]
    ([CustomerKey]
      ,[AgentKey]
      ,[CallDate]
      ,[Start_TM]
      ,[End_TM]
      ,[Status]
      ,[Satisfaction]
      ,[FirstResolved]
      ,[HandleType_Key]
      ,[ServiceType_Key]
      ,[SeverityType_Key]
      ,[CallReason_Key]
      ,[NPS]
      ,[ProductKey]
      ,[CustomerTier]
      ,[CustomerSegment]
      ,[CloseDate])
 SELECT TOP 50 
    [CustomerKey]
      ,[AgentKey]
      ,[CallDate]
      ,[Start_TM]
      ,[End_TM]
      ,[Status]
      ,[Satisfaction]
      ,[FirstResolved]
      ,[HandleType_Key]
      ,[ServiceType_Key]
      ,[SeverityType_Key]
      ,[CallReason_Key]
      ,[NPS]
      ,[ProductKey]
      ,[CustomerTier]
      ,[CustomerSegment]
      ,[CloseDate] 
    FROM [dbo].[CDR]



SELECT TOP 1000 * from [dbo].[CDR];
SELECT TOP 1000 * from [dbo].[DimAgent];
SELECT TOP 1000 * from [dbo].[DimCustomer];
USE CCBISDW
SELECT TOP 1000 * FROM [dbo].[DimDate]
alter table [CCBIS].[dbo].[DimAgent] alter column [AgentID] drop not for replication;
UPDATE [CCBIS].[dbo].[DimAgent] SET [AgentID] = 1 WHERE [FirstName] = 'Jarrod' AND [LastName] = 'Todd'