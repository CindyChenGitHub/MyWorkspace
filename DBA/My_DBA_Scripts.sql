-- list some of the database system info
SELECT @@SERVERNAME as ServerName, @@SERVICENAME as ServiceName, @@VERSION as Version
-- List all the database list in the Server (include System Datases and User Databases)
SELECT * FROM SYS.databases
--Handle [NT AUTHORITY\SYSTEM]
IF NOT EXISTS(SELECT * FROM syslogins WHERE Name = 'NT AUTHORITY\SYSTEM')
    CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS
EXEC sp_helpsrvrolemember 'NT AUTHORITY\SYSTEM', 'sysadmin'