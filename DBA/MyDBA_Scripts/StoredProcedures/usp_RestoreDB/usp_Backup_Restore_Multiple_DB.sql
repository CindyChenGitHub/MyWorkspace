USE [DBA_Config_DB]
GO
/****** Object:  StoredProcedure [dbo].[usp_Backup_Restore_Multiple_DB]    Script Date: 8/27/2021 12:21:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- Run example1: usp_Backup_Restore_Single_DB '0243Testing1', '0243Testing7'
-- Run example2: usp_Backup_Restore_Single_DB '0243Testing1 , 0243Testing2 , 0243Testing3, 0243Testing7',  , 1, 1
-- Run example3: usp_Backup_Restore_Single_DB '0243Testing1', '0243Testing7', @exectType = 1, @overwrite = 1, @kill = 1, @stopat = '2021-07-05 09:00'
ALTER PROCEDURE [dbo].[usp_Backup_Restore_Multiple_DB] 
	-- Add the parameters for the stored procedure here
	@dbsrc VARCHAR(50)
	, @dbdestList VARCHAR(MAX)
	, @exectType int = 0 -- 0: print SQL; 1: exect
	, @overwrite int = 0
	, @kill int = 0
	, @stopat VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	-- Get destination db list
	DROP Table IF EXISTS #dbdestList
	CREATE TABLE #dbdestList
	(
	    String VARCHAR(MAX)
	)
	INSERT #dbdestList SELECT @dbdestList
	--select * from #dbdestList

	-- Sprite destination db list 
	DROP Table IF EXISTS #tmp
	Declare @dbdest Varchar(200)
	Declare dbList Cursor For
		WITH #tmp(DataItem, String) AS
		(
			SELECT
				LEFT(String, CHARINDEX(',', String + ',') - 1),
				STUFF(String, 1, CHARINDEX(',', String + ','), '')
			FROM #dbdestList
			UNION all

			SELECT
			   LEFT(String, CHARINDEX(',', String + ',') - 1),
			   STUFF(String, 1, CHARINDEX(',', String + ','), '')
		  FROM #tmp
		   WHERE
		      String > ''
		)
		SELECT
		   ltrim(rtrim(DataItem))
		FROM #tmp
	-- Exectute restore single procedure for each destination db
	Open dbList
	Fetch Next From dbList Into @dbdest
	While @@FETCH_STATUS = 0
	Begin
		print ('From: ' + @dbsrc + ' To: ' + @dbdest)
		EXECUTE usp_Backup_Restore_Single_DB @dbsrc, @dbdest, @exectType, @overwrite, @kill, @stopat
		Fetch Next From dbList Into @dbdest
	END
	Close dbList
	Deallocate dbList
	SET NOCOUNT OFF
END
