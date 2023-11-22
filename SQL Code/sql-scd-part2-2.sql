--Initial setup----------------------------------------
use AdventureWorks2017
go 

drop table if exists Demo.PersonPhoneLarge
go 

drop table if exists Demo.PersonLarge
go 

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
from Demo.PersonLarge_bak;

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



-- use AdventureWorksDW2017
-- go 

DROP TABLE if exists [Demo].[DimCustomerLarge]
GO

/****** Object:  Table [Demo].[PersonLarge]    Script Date: 4/6/2019 11:04:18 AM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

CREATE TABLE [Demo].[DimCustomerLarge](
	[pk_CustomerLargeKey] INT NOT NULL IDENTITY(1,1) ,
	[nk_BusinessEntityID] [int] NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[PhoneNumber] nvarchar(25) NULL,
	[PhoneType] nvarchar(50),
	DateInserted datetime default getdate(),
	DateUpdated datetime default getdate()
 CONSTRAINT [PK_customerLarge] PRIMARY KEY CLUSTERED 
(
	[pk_CustomerLargeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


--USE [AdventureWorksDW2017]
--GO

DROP INDEX if exists [ix_DimCustomerLarge_NK] ON [Demo].[DimCustomerLarge]
GO

CREATE NONCLUSTERED INDEX [ix_DimCustomerLarge_NK] ON [Demo].[DimCustomerLarge]
(
	[nk_BusinessEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



use AdventureWorks2017;
go 

create or alter view Demo.vDimCustomerLarge as 
(
select p.[BusinessEntityID] as nk_BusinessEntityID
      ,p.[Title]
      ,p.[FirstName]
      ,p.[MiddleName]
      ,p.[LastName]
	  ,phn.PhoneNumber
	  --,pt.Name as PhoneType
from Demo.PersonLarge p 
left outer join Demo.PersonPhoneLarge phn on p.BusinessEntityID = phn.BusinessEntityID
left outer join Person.PhoneNumberType pt on phn.PhoneNumberTypeID = pt.PhoneNumberTypeID
)

go 
-------------------------------------------------------

select * from Demo.DimCustomerLarge



---------- Now for SSIS -----------

--- then Test it by updating large number of records


select * from demo.PersonLarge

--- test 1

update demo.PersonLarge
set title = Title + '.'
where right(Title,1) <> '.' and len(Title) > 1  


-- test 2 -- > adding phone type column
  

  
alter view Demo.vDimCustomerLarge as 
(
select p.[BusinessEntityID] as nk_BusinessEntityID
      ,p.[Title]
      ,p.[FirstName]
      ,p.[MiddleName]
      ,p.[LastName]
	  ,phn.PhoneNumber
	  ,pt.Name as PhoneType
from Demo.PersonLarge p 
left outer join Demo.PersonPhoneLarge phn on p.BusinessEntityID = phn.BusinessEntityID
left outer join Person.PhoneNumberType pt on phn.PhoneNumberTypeID = pt.PhoneNumberTypeID

