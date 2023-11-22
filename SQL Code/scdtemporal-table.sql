--Initial setup - source data
use AdventureWorks2017test2
go 

drop schema if exists Demo
go
create schema Demo

drop table if exists Demo.PersonPhoneLarge
go 

drop table if exists Demo.PersonLarge

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Demo].[PersonLarge](
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
	[ModifiedDate] [nvarchar](50) NULL,
 CONSTRAINT [PK_PersonLarge] PRIMARY KEY CLUSTERED 
(
	[BusinessEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


insert into Demo.PersonLarge
select top 75000 *
from AdventureWorks2017.Demo.PersonLarge_bak;

go 


CREATE TABLE [Demo].[PersonPhoneLarge](
	[BusinessEntityID] [int] NOT NULL foreign key references Demo.PersonLarge([BusinessEntityID]),
	[PhoneNumber] [dbo].[Phone] NOT NULL,
	[PhoneNumberTypeID] [int] NOT NULL foreign key references Person.PhoneNumberTYpe([PhoneNumberTypeID]),
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_PersonPhoneLarge_BusinessEntityID_PhoneNumber_PhoneNumberTypeID] PRIMARY KEY CLUSTERED 
(
	[BusinessEntityID] ASC,
	[PhoneNumber] ASC,
	[PhoneNumberTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



insert into demo.PersonPhoneLarge
(
	BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	ModifiedDate
)
select  BusinessEntityID,
		PhoneNumber = FORMAT(ROUND(((9999999999 - 1111111111)*RAND(CAST(DATEDIFF(s,'1970-01-01 12:00:00',GETDATE()) As BIGINT)+(ROW_NUMBER() OVER(ORDER BY (SELECT(NULL)))) ) + 1111111111),0),'(###) ###-####'),
		ABS(CHECKSUM(NEWID())) % 3 + 1 as PhoneNumberTypeID,
		getdate()
from Demo.PersonLarge;

go 

create or alter view Demo.vDimCustomerTemporalTable as 
(
select p.[BusinessEntityID] as nk_BusinessEntityID
      ,p.[FirstName]
      ,p.[MiddleName]
      ,p.[LastName]
from Demo.PersonLarge p 
);

go 






if exists(select * from sys.tables where name = 'DimCustomerTemporalTable')	
	ALTER TABLE [Demo].[DimCustomerTemporalTable] SET ( SYSTEM_VERSIONING = OFF)

DROP TABLE if exists [Demo].[DimCustomerTemporalTable];
GO
DROP TABLE if exists [Demo].[DimCustomerTemporalTable_History];
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--Create temporal dimension table
CREATE TABLE [Demo].[DimCustomerTemporalTable]
(
	[pk_CustomerLargeKey] INT NOT NULL IDENTITY(1,1) primary key ,
	[nk_BusinessEntityID] [int] NOT NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[ValidFrom] datetime2 (2) GENERATED ALWAYS AS ROW START , 
	[ValidTo] datetime2 (2) GENERATED ALWAYS AS ROW END , 
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)  
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = demo.DimCustomerTemporalTable_History));
GO






















DROP INDEX if exists [ix_DimCustomerTemporalTable_uqBusinessKey] ON [Demo].[DimCustomerTemporalTable]
GO

CREATE UNIQUE NONCLUSTERED INDEX [ix_DimCustomerTemporalTable_uqBusinessKey] ON [Demo].[DimCustomerTemporalTable]
(
	[nk_BusinessEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO









DROP TABLE if exists [Demo].[stg_DimCustomerTemporalTable]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Demo].stg_DimCustomerTemporalTable(
	[nk_BusinessEntityID] [int] NOT NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL
 CONSTRAINT [PK_stg_DimCustomerTemporalTable] PRIMARY KEY CLUSTERED 
(
	[nk_BusinessEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE or ALTER PROCEDURE Demo.Merge_DimCustomerTemporalTable
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		Declare @RecordCount INT = 0;

		--Merge from the staging table into the final dimension table
		MERGE INTO Demo.DimCustomerTemporalTable tgt
		USING Demo.stg_DimCustomerTemporalTable src ON tgt.nk_BusinessEntityID = src.nk_BusinessEntityID
		WHEN MATCHED AND EXISTS 
		(	
			select src.[FirstName], src.[MiddleName], src.[LastName]
			except 
			select tgt.[FirstName], tgt.[MiddleName], tgt.[LastName]
		)
		THEN UPDATE
		SET 
			tgt.FirstName = src.FirstName,
			tgt.MiddleName = src.MiddleName,
			tgt.LastName = src.LastName
		WHEN NOT MATCHED BY TARGET THEN INSERT
		(
		   [nk_BusinessEntityID]
		  ,[FirstName]
		  ,[MiddleName]
		  ,[LastName]
		)
		VALUES
		(
			 src.[nk_BusinessEntityID]
			,src.[FirstName]
			,src.[MiddleName]
			,src.[LastName]
		);

		--Save the number of records touched by the MERGE statement and send the results back to SSIS
		SET @RecordCount = @@ROWCOUNT;
		SELECT @RecordCount as RecordCount;
	
END
GO


exec demo.Merge_DimCustomerTemporalTable

select * from demo.DimCustomerTemporalTable


select * from demo.stg_DimCustomerTemporalTable



create table demo.etlrun
(
RecordCount int
)

select * from demo.etlrun




-------------------- Test --------------------


--View the results after initial load
select * from demo.etlrun


select count(*)
from Demo.DimCustomerTemporalTable


select count(*)
from Demo.DimCustomerTemporalTable_History


select *
from Demo.DimCustomerTemporalTable
where nk_BusinessEntityID = 1




--Update a record and then re-run the ETL


update Demo.PersonLarge
set	   MiddleName = 'S.'
where  BusinessEntityID = 1;

go 





--Re-run ETL and then let's query the results again

select *
from demo.etlrun;

select count(*)
from Demo.DimCustomerTemporalTable;


select count(*)
from Demo.DimCustomerTemporalTable_History;


select *
from demo.DimCustomerTemporalTable
where nk_BusinessEntityID = 1;

select *
from demo.DimCustomerTemporalTable_History;








--And show a historical view of the data as well
declare @Datetime as datetime2(2) 
--set @Datetime = GETUTCDATE();
set @Datetime = dateadd(minute, -3, GETUTCDATE());

select *
from Demo.DimCustomerTemporalTable
FOR SYSTEM_TIME AS OF @Datetime
where nk_BusinessEntityID = 1

