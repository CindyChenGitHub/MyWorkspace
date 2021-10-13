USE [DBA_Config_DB]
GO
/****** Object:  StoredProcedure [dbo].[usp_Shrink_Logfile_Size]    Script Date: 10/4/2021 4:29:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Proc [dbo].[usp_Shrink_Logfile_Size]
AS
Begin
SET NOCOUNT ON

-- Get default backup path
DROP Table IF EXISTS #backuppath
CREATE Table #backuppath (item VARCHAR(50), bkpath VARCHAR(500))
INSERT INTO #backuppath
	EXECUTE [master].dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', 
			N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory'
-- select * from #backuppath

-- Gather Database file size
DROP Table IF EXISTS #filesize
CREATE Table #filesize (DbName VARCHAR(50), [FileName] VARCHAR(50), [type_desc] VARCHAR(10), 
		CurrentSizeMB INT,FreeSpaceMB INT)

Declare @qry varchar(max) = ''
select @qry = @qry + CASE WHEN @qry = '' THEN '' ELSE 'UNION ' + char(13) END
+ 'SELECT ''' + name + ''' AS DbName, name AS FileName, type_desc, size/128.0 AS CurrentSizeMB,'
+ char(13) + '    size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0 AS FreeSpaceMB'
+ char(13) + 'FROM [' + name + '].sys.database_files WHERE type IN (0,1)'
+ char(13)
from sys.sysdatabases WHERE dbid > 4 and name NOT LIKE 'ReportServer%' 
-- print @qry

INSERT INTO #filesize
	exec(@qry)
-- select * from #filesize

-- Query to shrink log file with size > 1GB
Declare @sql varchar(max) = ''
select  @sql = @sql + CASE WHEN @sql = '' THEN '' ELSE char(13) END
+ 'IF (select CurrentSizeMB From #filesize 
	Where FileName = ''' + name + ''' AND DbName = '''+ db_name(database_id) + ''') > 1024 '
+ char(13) + 'Begin'
+ char(13) + '    Use [' + db_name(database_id) + ']' 
+ char(13) + '    BACKUP LOG [' + db_name(database_id) + '] TO DISK = ''' 
	+ (select bkpath FROM #backuppath) + '\' + name + '.trn'''	
+ char(13) + '    DBCC SHRINKFILE (' + name + ', 100)'
--+ Char(13) + '    DBCC LOGINFO'
+ Char(13) + 'End'
+ Char(13)
From sys.master_files WHERE type_desc = 'LOG' AND database_id > 4
-- print @sql
exec (@sql) -- shrink files

exec (@qry) -- check file size

SET NOCOUNT OFF
END
