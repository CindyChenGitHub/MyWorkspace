USE [CCBISDW]
GO



CREATE FUNCTION [dbo].[GetBusinessDayCount](@startDate as Date, @endDate as Date)
RETURNS INT
AS
BEGIN
	-- If the startDate is NULL, return a NULL and exit.
	IF @startDate IS NULL
		RETURN NULL

	-- If the EndDate is NULL, return a NULL and exit.
	IF @endDate IS NULL
		RETURN NULL
	
	-- If parameters are in wrong order, return 0 and exit.
	IF @startDate > @endDate 
		RETURN 0

	RETURN (
		SELECT 
			SUM(counter.workday)
		FROM (
			SELECT 
				CASE
					-- Workday(a day is a weekday and not a holiday) counts 1
					WHEN WeekDayFlag = 1 and HolidayFlag = 0 THEN 1
					-- Otherwise, counts 0
					ELSE 0
				END as workday
			FROM dbo.DimDate
			WHERE fullDate BETWEEN @startDate and @endDate
		) as counter 
	)

END

GO


