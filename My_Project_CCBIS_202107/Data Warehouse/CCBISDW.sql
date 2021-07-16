USE [master]
GO

/****** Object:  Database [CCBISDW]    Script Date: 7/10/2021 11:46:35 AM ******/
CREATE DATABASE [CCBISDW]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CCBISDW', FILENAME = N'/var/opt/mssql/data/CCBISDW.mdf' , SIZE = 21504KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'CCBISDW_log', FILENAME = N'/var/opt/mssql/data/CCBISDW_log.ldf' , SIZE = 22144KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CCBISDW].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [CCBISDW] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [CCBISDW] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [CCBISDW] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [CCBISDW] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [CCBISDW] SET ARITHABORT OFF 
GO

ALTER DATABASE [CCBISDW] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [CCBISDW] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [CCBISDW] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [CCBISDW] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [CCBISDW] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [CCBISDW] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [CCBISDW] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [CCBISDW] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [CCBISDW] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [CCBISDW] SET  DISABLE_BROKER 
GO

ALTER DATABASE [CCBISDW] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [CCBISDW] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [CCBISDW] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [CCBISDW] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [CCBISDW] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [CCBISDW] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [CCBISDW] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [CCBISDW] SET RECOVERY FULL 
GO

ALTER DATABASE [CCBISDW] SET  MULTI_USER 
GO

ALTER DATABASE [CCBISDW] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [CCBISDW] SET DB_CHAINING OFF 
GO

ALTER DATABASE [CCBISDW] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [CCBISDW] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO

ALTER DATABASE [CCBISDW] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [CCBISDW] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO

ALTER DATABASE [CCBISDW] SET QUERY_STORE = OFF
GO

ALTER DATABASE [CCBISDW] SET  READ_WRITE 
GO
