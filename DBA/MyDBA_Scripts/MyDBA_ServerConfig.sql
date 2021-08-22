--==========================================================
-- Service level config
--==========================================================
------------------------------------------------------------
-- Display database info (include logic files)
------------------------------------------------------------
--## list some of the database system info
SELECT @@SERVERNAME as ServerName, @@SERVICENAME as ServiceName, @@VERSION as Version
--## List all the database list in the Server (include System Datases and User Databases)
SELECT * FROM SYS.databases
--## to send email from SQL instance (engine)
exec msdb..sp_send_dbmail -- ... provide parameters
--## Build-in error messages
SELECT * FROM master.sys.messages
SELECT * FROM master..syslanguages
------------------------------------------------------------
-- Add user [NT AUTHORITY\SYSTEM] to WINDOWS login user and 'sysadmin' server roll
------------------------------------------------------------
--# Create WINDOWS login user [NT AUTHORITY\SYSTEM]
IF NOT EXISTS(SELECT * FROM syslogins WHERE Name = 'NT AUTHORITY\SYSTEM')
    CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS
--# Add user [NT AUTHORITY\SYSTEM] to 'sysadmin' server roll
IF 1 <> (SELECT IS_SRVROLEMEMBER('sysadmin', 'SQL2K8\SQLDBAGRP'))  --if it works??
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
SELECT IS_SRVROLEMEMBER('sysadmin', 'NT AUTHORITY\SYSTEM')
------------------------------------------------------------
-- Add DBA group ex.[DA\DBA202107G2] to WINDOWS login user and 'sysadmin' server roll
------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM syslogins WHERE Name = 'SQL2K8\SQLDBAGRP')
    CREATE LOGIN [SQL2K8\SQLDBAGRP] FROM WINDOWS
IF 1 <> (SELECT IS_SRVROLEMEMBER('sysadmin', 'SQL2K8\SQLDBAGRP'))  --if it works??
    EXEC sp_addsrvrolemember 'SQL2K8\SQLDBAGRP', 'sysadmin'
------------------------------------------------------------
-- Disable 'sa' user from external login to SQL Server
------------------------------------------------------------
ALTER LOGIN sa DISABLE
------------------------------------------------------------
-- Check domain group member
------------------------------------------------------------
EXEC xp_logininfo 'SQL2K8\SQLDBAGRP', 'members'
------------------------------------------------------------
-- use T-SQL to enable Server Configuration
------------------------------------------------------------
--## Enable advanced configure
EXEC sp_configure 'show advanced options', 1
--RECONFIGURE
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

--==========================================================
-- Database level config
--==========================================================
------------------------------------------------------------
-- Check database owner
------------------------------------------------------------
--## List database info
EXEC sp_helpdb
EXEC sp_helpdb Orders
--## display database current owner
SELECT name, sid [Current owner ID], suser_sname(sid) [Current owner name]
    FROM sysdatabases  -- 0x01 is Hexidecimal '01' (0-9,a-f), 0x01 user - 'sa'
--## list database with owner not 'sa'
SELECT name, sid [Current owner ID], suser_sname(sid) [Current owner name]
    FROM sysdatabases
    WHERE suser_sname(sid) != 'sa'
    ORDER BY 1
--## Change database owner to 'sa'
--EXEC Orders..sp_changedbowner 'sa'
SELECT 'EXEC [' + name + ']..sp_changedbowner ''sa'''
	FROM sysdatabases
	WHERE suser_sname(sid) != 'sa'
	ORDER BY 1
IF EXISTS
	(SELECT *
		FROM sysdatabases
		WHERE suser_sname(sid) != 'sa'
        AND suser_sname(sid) = 'DA\DaTest0179')
	-----------------------------------------------------
	-------------Drag the auto scripts here--------------
	-----------------------------------------------------
------------------------------------------------------------
-- Check database version
------------------------------------------------------------
--## List database version
SELECT @@version  --'130' is version 2016
SELECT name, cmptlevel [DB Version] FROM sysdatabases
    WHERE name = 'master' -- the version of 'master' must be the version of Server
--## List databases that version not same with server    
SELECT * FROM sysdatabases
    WHERE cmptlevel NOT IN
    (SELECT cmptlevel FROM sysdatabases
        WHERE name = 'master')
--## change database version
ALTER DATABASE [Orders] SET compatibility_level = 110 -- '110' is 2012 version
--## Change database version to '130' (version 2016)
SELECT 'ALTER DATABASE [' + name + '] SET compatibility_level = 130'
	FROM sysdatabases
	WHERE cmptlevel NOT IN
    (SELECT cmptlevel FROM sysdatabases
        WHERE name = 'master')
IF EXISTS
    (SELECT * FROM sysdatabases
    WHERE cmptlevel NOT IN
        (SELECT cmptlevel FROM sysdatabases
        WHERE name = 'master'))
	-----------------------------------------------------
	-------------Drag the auto scripts here--------------
	-----------------------------------------------------
------------------------------------------------------------
-- Check and set database to FULL RECOVERY mode
------------------------------------------------------------
ALTER DATABASE [0179Orders] SET RECOVERY FULL
SELECT 'ALTER DATABASE [' + name + '] SET RECOVERY FULL'
	FROM sysdatabases
	WHERE name LIKE '0179%'
	-----------------------------------------------------
	-------------Drag the auto scripts here--------------
	-----------------------------------------------------