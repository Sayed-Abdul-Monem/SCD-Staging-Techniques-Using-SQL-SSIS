use AdventureWorks2017;
go 

drop table if exists Demo.PersonLarge_bak



--Create a backup table so that we can reset the person large table without re-importing data for future demos
CREATE TABLE [Demo].[PersonLarge_bak](
	[BusinessEntityID] [int] NOT NULL,
	[PersonType] [nvarchar](50) NULL,
	[NameStyle] [int] NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[Suffix] [nvarchar](50) NULL,
	[EmailPromotion] [int] NULL,
	[AdditionalContactInfo] [nvarchar](50) NULL,
	[Demographics] [nvarchar](50) NULL,
	[rowguid] [nvarchar](50) NULL,
	[ModifiedDate] [nvarchar](50) NULL
) ON [PRIMARY]
GO


BULK INSERT Demo.PersonLarge_bak
FROM 'C:\Users\Sayed Abdul-Monem\Downloads\Video\Dimentional Modeling Plurasight\dimensional-modeling-microsoft-sql-server-platform\03\demos\PersonLarge_bak.csv' 
WITH ( FIELDTERMINATOR =',', FIRSTROW = 1 )

GO

select * from demo.PersonLarge_bak
