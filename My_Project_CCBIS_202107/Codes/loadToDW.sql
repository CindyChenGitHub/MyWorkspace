use CCBISDW
BULK INSERT dbo.DimAgent
FROM '\var\tmp\DimAgent_DW.csv'
WITH(
    DATAFILETYPE = 'char', 
    FIRSTROW = 2, 
    FIELDTERMINATOR =',',
    ROWTERMINATOR ='0x0a')
GO
use CCBISDW
BULK INSERT dbo.DimCustomer
FROM '\var\tmp\DimCustomer_DW.csv'
WITH(
    DATAFILETYPE = 'char', 
    FIRSTROW = 2, 
    FIELDTERMINATOR =',',
    ROWTERMINATOR ='0x0a')
GO
use CCBISDW
BULK INSERT dbo.DimHandleType
FROM '\var\tmp\DimHandleType_DW.csv'
WITH(
    DATAFILETYPE = 'char', 
    FIRSTROW = 2, 
    FIELDTERMINATOR =',',
    ROWTERMINATOR ='0x0a')
GO
use CCBISDW
BULK INSERT dbo.DimProduct
FROM '\var\tmp\DimProduct_DW.csv'
WITH(
    DATAFILETYPE = 'char', 
    FIRSTROW = 2, 
    FIELDTERMINATOR =',',
    ROWTERMINATOR ='0x0a')
GO
use CCBISDW
BULK INSERT dbo.DimServiceType
FROM '\var\tmp\DimServiceType_DW.csv'
WITH(
    DATAFILETYPE = 'char', 
    FIRSTROW = 2, 
    FIELDTERMINATOR =',',
    ROWTERMINATOR ='0x0a')
GO
use CCBISDW
BULK INSERT dbo.DimSeverifyType
FROM '\var\tmp\DimSeverifyType_DW.csv'
WITH(
    DATAFILETYPE = 'char', 
    FIRSTROW = 2, 
    FIELDTERMINATOR =',',
    ROWTERMINATOR ='0x0a')
GO
use CCBISDW
BULK INSERT dbo.FactCDR
FROM '\var\tmp\FactCDR_DW.csv'
WITH( 
    DATAFILETYPE = 'char', 
    FIRSTROW = 2, 
    FIELDTERMINATOR =',',
    ROWTERMINATOR ='0x0a')
GO