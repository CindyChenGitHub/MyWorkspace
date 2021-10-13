/*************************************************************************************/
/*************************** Warnning: Be careful to do it ***************************/
/*************************************************************************************/

/* Delete backup and restore history infomation for databases */
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'0179Orders_Org'
GO
USE [master]
GO
/* Drop Object:  Database [0179Orders_Org] */
DROP DATABASE [0179Orders_Org]
GO