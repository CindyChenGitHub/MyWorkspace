--## list some of the database system info
SELECT @@SERVERNAME as ServerName, @@SERVICENAME as ServiceName, @@VERSION as Version

--## List all the database list in the Server (include System Datases and User Databases)
SELECT * FROM SYS.databases

------------------------------------------------------------
-- Add user [NT AUTHORITY\SYSTEM] to WINDOWS login user and 'sysadmin' server roll
------------------------------------------------------------
--# Create WINDOWS login user [NT AUTHORITY\SYSTEM]
IF NOT EXISTS(SELECT * FROM syslogins WHERE Name = 'NT AUTHORITY\SYSTEM')
    CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS

--# Add user [NT AUTHORITY\SYSTEM] to 'sysadmin' server roll
IF NOT EXISTS(SELECT IS_SRVROLEMEMBER('sysadmin', 'NT AUTHORITY\SYSTEM'))
    EXEC sp_addsrvrolemember 'NT AUTHORITY\SYSTEM', 'sysadmin'

--## PS1: Other Mathod to add user to 'sysadmin' server roll
IF NOT EXISTS(
    SELECT member.name
    FROM sys.server_role_members AS serverRole
    JOIN sys.server_principals AS role ON serverRole.role_principal_id = role.principal_id
    JOIN sys.server_principals AS member ON serverRole.member_principal_id = member.principal_id
    WHERE role.name = 'sysadmin' AND member.name = 'NT AUTHORITY\SYSTEM')
    -- sp_addsrvrolemember (Add server roll member）， username， roll
    EXEC sp_addsrvrolemember 'NT AUTHORITY\SYSTEM', 'sysadmin'
--## PS2: Display the sysadmin users
EXEC sp_helpsrvrolemember 'sysadmin'

------------------------------------------------------------
-- Add user group [DA\DBA202107G2] to WINDOWS login user and 'sysadmin' server roll
------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM syslogins WHERE Name = 'DA\DBA202107G2')
    CREATE LOGIN [DA\DBA202107G2] FROM WINDOWS
IF NOT EXISTS(SELECT IS_SRVROLEMEMBER('sysadmin', 'DA\DBA202107G2'))
    EXEC sp_addsrvrolemember 'DA\DBA202107G2', 'sysadmin'
------------------------------------------------------------
-- Disable 'sa' user from external login to SQL Server
------------------------------------------------------------
ALTER LOGIN sa DISABLED
------------------------------------------------------------
-- Check domain group member
------------------------------------------------------------
EXEC xp_logininfo 'DA\DBAStudents2020Jan', 'members'
------------------------------------------------------------
-- use T-SQL to enable Server Configuration
------------------------------------------------------------
--## Enable advanced configure
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
--## Turn on necessary Server configurations
EXEC sp_configure 'Ad Hoc Distributed Queries', 1
EXEC sp_configure 'backup compression default', 1
EXEC sp_configure 'clr enabled', 1
EXEC sp_configure 'Database Mail XPs', 1
EXEC sp_configure 'remote admin connections', 1
EXEC sp_configure 'xp_cmdshell', 1
RECONFIGURE
--## List sp_configure
EXEC sp_configure

--## Example of xp_cmdshell
EXEC xp_cmdshell 'dir E:'
