-- Query the jobs which occupied the named database
USE master
GO
SELECT convert(sysname, rtrim(loginame)) as loginname, db_name(dbid) as dbname, hostname, program_name
FROM sys.sysprocesses with (nolock)
WHERE db_name(dbid) = 'yourDatabaseName'