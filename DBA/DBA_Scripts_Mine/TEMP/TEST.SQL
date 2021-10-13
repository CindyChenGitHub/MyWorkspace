use [DBA_Config_DB]
GO
paraTest 1

	declare	@p1 VARCHAR(10) = '1'; 
	declare	@p2 VARCHAR(10) = '2'; 
	declare	@p3 VARCHAR(10) = ''; 
	declare	@p4 VARCHAR(10) = '5'; 
	declare	@p5 VARCHAR(10) = ''; 
	declare	@p6 VARCHAR(10) = ''; 
	declare	@p7 VARCHAR(10) = ''; 
	declare	@p8 VARCHAR(10) = ''; 
	declare	@p9 VARCHAR(10) = 'all+'; 
	declare	@p10 VARCHAR(10) = '' 

	DROP Table IF EXISTS #allConfigList
	CREATE TABLE #allConfigList
	(
	    config_ID INT Identity,
		config_Name VARCHAR(20),
		config_Item VARCHAR(100)
	)
	INSERT INTO #allConfigList VALUES 
		('Hoc', 'Ad Hoc Distributed Queries'), 
		('compression', 'backup compression default'), 
		('clr', 'clr enabled'), 
		('db mail XPs', 'Database Mail XPs'), 
		('remote', 'remote admin connections'), 
		('cmd shell', 'xp_cmdshell')
	SELECT * FROM #allConfigList 


	DROP Table IF EXISTS #actionList
	CREATE TABLE #actionList
	(
	    ID INT Identity,
		parmName VARCHAR(10),
		parmVal VARCHAR(10)
	)
	INSERT INTO #actionList VALUES
		('@p1', @p1), 
		('@p2', @p2), 
		('@p3', @p3), 
		('@p4', @p4), 
		('@p5', @p5), 
		('@p6', @p6), 
		('@p7', @p7), 
		('@p8', @p8), 
		('@p9', @p9), 
		('@p10', @p10)
	SELECT * FROM #actionList 

	
	IF (SELECT COUNT(1) FROM #actionList WHERE upper(ltrim(rtrim(parmVal))) = 'ALL') > 0
		OR (SELECT COUNT(1) FROM #actionList WHERE ltrim(rtrim(parmVal)) IS NOT NULL) = 0
		BEGIN
			SELECT config_ID, config_Name, config_Item, ('EXEC sp_configure ' + config_Item + ', 1') as config_query FROM #allConfigList
		END
	ELSE
		BEGIN
			SELECT c.parmVal, a.config_Name, a.config_Item, ('EXEC sp_configure ' + a.config_Item + ', 1') as config_query FROM #actionList c
				INNER JOIN #allConfigList a
				ON ltrim(rtrim(c.parmVal)) = CAST(a.config_ID AS VARCHAR)
			
			DROP Table IF EXISTS #tempTable
			Declare @tempString Varchar(200)
			Declare actionList Cursor For
				WITH #tempTable(DataItem, String) AS
				(
				SELECT config_query FROM #tempTable
				)
		SELECT
		   ltrim(rtrim(DataItem))
		FROM #tempTable
		END