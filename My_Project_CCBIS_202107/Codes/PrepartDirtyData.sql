USE CCBIS
INSERT INTO [dbo].[DimAgent](FirstName, LastName, [Group], [Location]) values ('Jarrod', 'Todd', 'Level 1', 'London')
UPDATE [CCBIS].[dbo].[CDR] SET NPS=12 WHERE CDRID=1
UPDATE [CCBIS].[dbo].[CDR] SET Satisfaction=7 WHERE CDRID=3
UPDATE [CCBIS].[dbo].[DimCustomer] SET LastName=null WHERE CustomerKey=11002
SELECT TOP 1000 * from [dbo].[CDR];
SELECT TOP 1000 * from [dbo].[DimAgent];
SELECT TOP 1000 * from [dbo].[DimCustomer];
USE CCBISDW
SELECT TOP 1000 * FROM [dbo].[DimDate]