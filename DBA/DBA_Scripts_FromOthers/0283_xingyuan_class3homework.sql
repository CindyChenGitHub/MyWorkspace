--drop for trial and error
drop procedure dbo.USP_DBA_sp_Configure

--create procedure
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,Xingyuan Mu>
-- Create date: <Create Date,2021-09-30>
-- Description:	<Description,customized configurations,>
-- =============================================
create PROCEDURE dbo.USP_DBA_sp_Configure @Param1 varchar(3) = 'ALL'
AS
DECLARE @var_n as int = 6
declare @i as int = 1
declare @str as varchar(50)
declare @feature_list table (id int, feature varchar(50))
insert into @feature_list (id, feature) values (1, 'Ad Hoc Distributed Queries'),
(2, 'backup compression default'),
(3, 'clr enabled'),
(4, 'Database Mail XPs'),
(5, 'remote admin connections'),
(6, 'xp_cmdshell')

	IF UPPER(@Param1) = 'ALL'
	BEGIN
		while @i < @var_n + 1
			BEGIN
			set @str = (select feature from @feature_list where id = @i)
			exec sp_configure @str, 1
			set @i = @i + 1
			END
    reconfigure
	END
	ELSE
	BEGIN
		set @str = (select feature from @feature_list where id = CAST(@Param1 as int))
		exec sp_configure @str, 1
		reconfigure
	END
GO

--test result
exec dbo.USP_DBA_sp_Configure 'all'
exec dbo.USP_DBA_sp_Configure '6'