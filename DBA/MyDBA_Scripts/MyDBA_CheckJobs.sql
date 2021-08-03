--## Find the DB maintenance SSIS package
SELECT * FROM msdb..sysssispackages
    WHERE name Like 'SysDB%'
--## Find the DB maintenance job that executes the package
SELECT * FROM msdb..sysjobs
    WHERE name Like 'SysDB%'
--## Find the job's steps
SELECT * FROM msdb..sysjobsteps
    WHERE job_id IN
        (SELECT job_id FROM msdb..sysjobs
            WHERE name Like 'SysDB%')
SELECT j.name [Job],
       js.step_name [Step Name], 
       js.database_name [Database]
    FROM msdb..sysjobs j
    JOIN msdb..sysjobsteps js
    ON j.job_id = js.job_id
    WHERE j.name Like 'SysDB%'
--## Search job running history
SELECT * FROM msdb..sysjobhistory jh
	JOIN msdb..sysjobs j ON jh.job_id = j.job_id
	WHERE j.name LIKE 'SysDB%'
--## List job history since today
SELECT j.name [Job]
	 , jh.step_name
	 , jh.message
	 , jh.run_date
	 , jh.run_time
	 , jh.run_duration
	FROM msdb..sysjobhistory jh
	JOIN msdb..sysjobs j
	ON jh.job_id = j.job_id
	WHERE j.name LIKE 'SysDB%'
		AND convert(date, convert(varchar,jh.run_date)) >= convert(date,getdate())
--## List job history since yestoday
SELECT j.name [Job]
	 , jh.step_name
	 , jh.message
	 , jh.run_date
	 , jh.run_time
	 , jh.run_duration
	FROM msdb..sysjobhistory jh
	JOIN msdb..sysjobs j
	ON jh.job_id = j.job_id
	WHERE j.name LIKE 'SysDB%'
		AND convert(date, convert(varchar,jh.run_date)) >= dateadd(day, -1, convert(date,getdate()))