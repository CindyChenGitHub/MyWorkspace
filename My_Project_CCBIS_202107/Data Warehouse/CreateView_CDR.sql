



CREATE VIEW [dbo].[CustomerService]
as
select 
CDR.CDRID,
CDR.CallDate,
CDR.Start_TM,
CDR.End_TM,
CDR.CloseDate,
CDR.Status,
CDR.Satisfaction,
CDR.FirstResolved,
CDR.NPS,
CDR.CustomerTier,
CDR.CustomerSegment,
GEO.[PostalCode] as Customer_PostalCode,
GEO.[EnglishCountryRegionName] AS Customer_Country,
SEVT.SeverityType_Desc AS SeverityType,
SERT.ServiceType_Desc AS ServiceType,
HANT.HandleType_Desc AS HandleType,
Agent.FirstName + ' ' +Agent.LastName+'('+ convert(varchar(5),Agent.AgentID )+')' as Agent ,
Agent.[Group] as [Group],
PRO.Name as Product,
PRG.Name as ProductGroup,
convert(varchar,DD.[ReportWeekStart])+'--'+convert(varchar,DD.[ReportWeekEnd]) AS ReportWeek,
DD.[ReportWeekNumber] as ReportWeekNumber,
case when [Status]='Processed' then datediff(dd,CallDate,CloseDate) end as DaystoResolved
from CDR 
left join DimCustomer CUS ON CDR.CustomerKey=CUS.CustomerKey
left join [dbo].[DimDate] DD on CDR.CallDate =DD.FullDate
left join [dbo].[DimGeography] GEO ON CUS.GeographyKey=GEO.GeographyKey 
left join DimSeverifyType SEVT ON CDR.SeverityType_Key =SEVT.SeverityType_Key
left join DimServiceType SERT ON CDR.ServiceType_Key =SERT.ServiceType_Key
left join DimHandleType HANT ON CDR.HandleType_Key =HANT.HandleType_Key
left join DimAgent Agent on CDR.AgentKey = Agent.AgentID 
left join DimProduct PRO on CDR.ProductKey = PRO.Product_Key 
left join DimProductGroup PRG on PRO.ProductGroup_Key = PRG.ProductGroup_Key 






