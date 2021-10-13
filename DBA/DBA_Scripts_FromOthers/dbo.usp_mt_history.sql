USE [DBA_Config_DB]
GO
/****** Object:  StoredProcedure [dbo].[usp_mt_history]    Script Date: 10/4/2021 4:28:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_mt_history] (@startdate datetime='', @enddate datetime='' )
AS
BEGIN

if (@enddate='')
begin
	set @enddate = getdate()
end

if (@startdate='')
	-- list history since today
	select j.name [Job], jh.step_name, jh.message,
		   jh.run_date, jh.run_time, jh.run_duration
	from msdb..sysjobhistory jh join msdb..sysjobs j
	on jh.job_id = j.job_id 
	where  convert(date, convert(varchar, jh.run_date)) <=
   convert(date, @enddate)
   else
   	select j.name [Job], jh.step_name, jh.message,
		   jh.run_date, jh.run_time, jh.run_duration
	from msdb..sysjobhistory jh join msdb..sysjobs j
	on jh.job_id = j.job_id 
	where     convert(date, @startdate) <= convert(date, convert(varchar, jh.run_date)) and
	convert(date, convert(varchar, jh.run_date)) <= convert(date, @enddate)

END
