
use AdventureWorks2017test1
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
from AdventureWorks2017.demo.PersonLarge_bak;

go 

-------------


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



------------------------------------------------------------------------

create or alter view Demo.vDimCustomerLarge as 
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
);

go 


------------------------------------------------------------


use AdventureWorksDW2017test1
go

create schema Demo
go

DROP TABLE if exists [Demo].[DimCustomerLarge]
GO

/****** Object:  Table [Demo].[PersonLarge]    Script Date: 4/6/2019 11:04:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Demo].[DimCustomerLarge](
	[pk_CustomerLargeKey] INT NOT NULL IDENTITY(1,1) ,
	[nk_BusinessEntityID] [int] NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[PhoneNumber] nvarchar(25) NULL,
	[PrevPhoneNumber] nvarchar(25) NULL,
	[PhoneType] nvarchar(50),
	StartDate datetime ,
	EndDate datetime ,
	DateInserted datetime default getdate(),
	DateUpdated datetime default getdate()
 CONSTRAINT [PK_PersonLarge] PRIMARY KEY CLUSTERED 
(
	[pk_CustomerLargeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO





/****** Object:  Index [ix_DimCustomerLarge_uqBusinessKey]    Script Date: 4/14/2019 3:49:02 PM ******/
DROP INDEX if exists [ix_DimCustomerLarge_uqBusinessKey] ON [Demo].[DimCustomerLarge]
GO

/****** Object:  Index [ix_DimCustomerLarge_uqBusinessKey]    Script Date: 4/14/2019 3:49:02 PM ******/
CREATE  NONCLUSTERED INDEX [ix_DimCustomerLarge_uqBusinessKey] ON [Demo].[DimCustomerLarge]
(
	[nk_BusinessEntityID] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO





/****** Object:  Index [ix_DimCustomerLarge_DateInsertedUpdated]    Script Date: 4/14/2019 3:49:57 PM ******/
DROP INDEX if exists [ix_DimCustomerLarge_DateInsertedUpdated] ON [Demo].[DimCustomerLarge]
GO

/****** Object:  Index [ix_DimCustomerLarge_DateInsertedUpdated]    Script Date: 4/14/2019 3:49:57 PM ******/
CREATE NONCLUSTERED INDEX [ix_DimCustomerLarge_DateInsertedUpdated] ON [Demo].[DimCustomerLarge]
(
	[DateInserted] ASC,
	[DateUpdated] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


------------------------------------------------------------

 use AdventureWorksDW2017test1
 go

DROP TABLE if exists [Demo].[stg_DimCustomerLarge]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Demo].[stg_DimCustomerLarge](
	[nk_BusinessEntityID] [int] NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[PhoneNumber] nvarchar(25) NULL,
	[PhoneType] nvarchar(50)
 CONSTRAINT [PK_stg_DimCustomerLarge] PRIMARY KEY CLUSTERED 
(
	[nk_BusinessEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


----------------------------- Merge Procedure--------------------


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE or ALTER PROCEDURE Demo.Merge_DimCustomerLarge
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		Declare @RecordCount INT = 0;

		--Merge from the staging table into the final dimension table
		MERGE INTO Demo.DimCustomerLarge tgt
		USING Demo.stg_DimCustomerLarge src ON tgt.nk_BusinessEntityID = src.nk_BusinessEntityID
		WHEN MATCHED AND EXISTS 
		(	/*
				Make sure at least 1 column is different; using the EXCEPT keyword handles NULL comparisons appropriately.  
				It is the equivalent of writing out: 
					WHEN MATCHED AND 
					(
						COALESCE(src.Attribute1,'Value That Would Never Exist in Att1') <> COALESCE(tgt.Attribute1,'Value That Would Never Exist in Att1') OR 
						COALESCE(src.Attribute2,'Value That Would Never Exist in Att2') <> COALESCE(tgt.Attribute2,'Value That Would Never Exist in Att2') OR 
						COALESCE(src.Attribute2,'Value That Would Never Exist in Att3') <> COALESCE(tgt.Attribute2,'Value That Would Never Exist in Att3') OR 
						...
					)
			*/
			select src.[Title], src.[FirstName], src.[MiddleName], src.[LastName], src.[PhoneNumber], src.[PhoneType]
			except 
			select tgt.[Title], tgt.[FirstName], tgt.[MiddleName], tgt.[LastName], tgt.[PhoneNumber], tgt.[PhoneType]
		)
		THEN UPDATE
		SET 
			tgt.Title = src.Title,
			tgt.FirstName = src.FirstName,
			tgt.MiddleName = src.MiddleName,
			tgt.LastName = src.LastName,
			tgt.PhoneNumber = src.PhoneNumber,
			tgt.PhoneType = src.PhoneType,
			tgt.DateUpdated = getdate()
		WHEN NOT MATCHED BY TARGET THEN INSERT
		(
		   [nk_BusinessEntityID]
		  ,[Title]
		  ,[FirstName]
		  ,[MiddleName]
		  ,[LastName]
		  ,[PhoneNumber]
		  ,[PhoneType]
		)
		VALUES
		(
			 src.[nk_BusinessEntityID]
			,src.[Title]
			,src.[FirstName]
			,src.[MiddleName]
			,src.[LastName]
			,src.[PhoneNumber]
			,src.[PhoneType]
		);

		--Save the number of records touched by the MERGE statement and send the results back to SSIS
		SET @RecordCount = @@ROWCOUNT;
		SELECT @RecordCount;
	
END
GO
----------------
drop table if exists  demo.etlrun
go 

create table demo.etlrun
(
record_count int
)

-------------------- Test 1--------------------

select * from demo.etlrun



----- delete from demo.DimCustomerLarge

----- select * from demo.DimCustomerLarge


---- Test2-------

--Update a large chunk of records to demonstrate performance improvement over SSIS SCD component
use AdventureWorks2017test1;
go 

--56,297 updates
update Demo.PersonLarge
set Title = Title + '.' 
WHERE right(Title,1) <> '.' and len(title) > 1;

go 


----- to see the number of affected rows---------
use AdventureWorksDW2017test1;
go 
select * from demo.etlrun
go







--------------------------------------SCD_ALL_TYPES USING MERGE ------------------

use AdventureWorksDW2017test1;
go 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE or ALTER PROCEDURE Demo.Merge_DimCustomerLarge_AllSCDTypes
	@PackageStartTime date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @RecordCount INT = 0;


	/*
	[Title]			= Type 1
	[FirstName]		= Type 2
	[MiddleName]	= Type 2
	[LastName]		= Type 2
	[PhoneNumber]	= Type 3
	[PhoneType]		= Type 1
	*/


		--Type 1 and 3 changes
		MERGE INTO Demo.DimCustomerLarge tgt
		USING Demo.stg_DimCustomerLarge src ON tgt.nk_BusinessEntityID = src.nk_BusinessEntityID
		WHEN MATCHED AND EXISTS 
		(	
			select src.[Title], src.[PhoneNumber], src.[PhoneType]
			except 
			select tgt.[Title], tgt.[PhoneNumber], tgt.[PhoneType]
		)
		THEN UPDATE
		SET 
			tgt.Title = src.Title,
			tgt.PhoneNumber = src.PhoneNumber,
			tgt.PrevPhonenumber = CASE WHEN src.PhoneNumber <> tgt.PhoneNumber THEN tgt.PhoneNumber ELSE tgt.PrevPhoneNumber END,
			tgt.PhoneType = src.PhoneType,
			tgt.DateUpdated = @PackageStartTime
		WHEN NOT MATCHED BY TARGET THEN INSERT
		(
		   [nk_BusinessEntityID]
		  ,[Title]
		  ,[FirstName]
		  ,[MiddleName]
		  ,[LastName]
		  ,[PhoneNumber]
		  ,[PhoneType]
		  ,StartDate
		  ,EndDate
		  ,DateInserted
		  ,DateUpdated
		)
		VALUES
		(
			 src.[nk_BusinessEntityID]
			,src.[Title]
			,src.[FirstName]
			,src.[MiddleName]
			,src.[LastName]
			,src.[PhoneNumber]
			,src.[PhoneType]
			,@PackageStartTime
			,NULL
			,@PackageStartTime
			,@PackageStartTime
		);




		
	IF OBJECT_ID('tempdb..#DimCustomerLarge') IS NOT NULL
    DROP TABLE #DimCustomerLarge;

	CREATE TABLE #DimCustomerLarge
	(
	[nk_BusinessEntityID] [int] NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[PhoneNumber] nvarchar(25) NULL,
	[PrevPhoneNumber] nvarchar(25) NULL,
	[PhoneType] nvarchar(50) NULL,
	StartDate datetime NULL,
	EndDate datetime NULL
	);


	--Type 2 Changes
	INSERT INTO #DimCustomerLarge
		   ([nk_BusinessEntityID], [Title] ,[FirstName] ,[MiddleName] ,[LastName] ,[PhoneNumber], [PrevPhoneNumber], [PhoneType], StartDate, EndDate)
	SELECT	[nk_BusinessEntityID], [Title] ,[FirstName] ,[MiddleName] ,[LastName] ,[PhoneNumber], [PrevPhoneNumber], [PhoneType], StartDate, EndDate	
    From (
		MERGE INTO Demo.DimCustomerLarge tgt
		USING Demo.stg_DimCustomerLarge src ON tgt.nk_BusinessEntityID = src.nk_BusinessEntityID
		WHEN MATCHED AND tgt.EndDate IS NULL AND EXISTS 
		(	
			select src.[FirstName], src.[MiddleName], src.[LastName]
			except 
			select tgt.[FirstName], tgt.[MiddleName], tgt.[LastName]
		)
		THEN UPDATE
		SET 
			tgt.EndDate = @PackageStartTime,
			tgt.DateUpdated = @PackageStartTime
		WHEN NOT MATCHED BY TARGET THEN INSERT
		(
		   [nk_BusinessEntityID]
		  ,[Title]
		  ,[FirstName]
		  ,[MiddleName]
		  ,[LastName]
		  ,[PhoneNumber]
		  ,[PhoneType]
		  ,StartDate
		  ,EndDate
		  ,DateInserted
		  ,DateUpdated
		)
		VALUES
		(
			 src.[nk_BusinessEntityID]
			,src.[Title]
			,src.[FirstName]
			,src.[MiddleName]
			,src.[LastName]
			,src.[PhoneNumber]
			,src.[PhoneType]
			,@PackageStartTime
			,NULL
			,@PackageStartTime
			,@PackageStartTime
		)
		Output $ACTION ActionOut, src.[nk_BusinessEntityID], src.[Title], src.[FirstName], src.[MiddleName], src.[LastName], 
			src.[PhoneNumber], inserted.PrevPhoneNumber, src.[PhoneType], @PackageStartTime as StartDate, NULL as EndDate) AS MergeOut
	WHERE  MergeOut.ActionOut = 'UPDATE';


	/*
	We use a temp table, and then insert into the dimension table, to avoid this error message:
		"The target table 'TableName' of the INSERT statement cannot be on either side of a (primary key, foreign key) relationship 
		when the FROM clause contains a nested INSERT, UPDATE, DELETE, or MERGE statement. Found reference constraint 'ConstraintName'."

	This only applies if the dimension table has foreign key relationships defined
	*/
	insert into Demo.DimCustomerLarge
	([nk_BusinessEntityID], [Title] ,[FirstName] ,[MiddleName] ,[LastName] ,[PhoneNumber], PrevPhoneNumber ,[PhoneType], StartDate, EndDate, DateInserted, DateUpdated)
	select [nk_BusinessEntityID], [Title] ,[FirstName] ,[MiddleName] ,[LastName] ,[PhoneNumber], PrevPhoneNumber ,[PhoneType], StartDate, EndDate, @PackageStartTime, @PackageStartTime
	from #DimCustomerLarge;


		--Save the number of records touched by the MERGE statement and send the results back to SSIS
		select COUNT(*) as RecordCount
		from DimCustomerLarge 
		where DateInserted = @PackageStartTime or DateUpdated = @PackageStartTime;


	
END
GO

--- now let's change the procedure in the SSIS block(Merge to dimention table)

----------- test---------------



---- reset dimention table-----
delete from demo.DimCustomerLarge
go

use AdventureWorksDW2017test1;
go 

select * from demo.etlrun
go

use AdventureWorks2017test1;
go 


--Type 2 Change
update demo.PersonLarge
set MiddleName = 'Rogerr454'
where [BusinessEntityID] = 1;



use AdventureWorksDW2017test1
go 

select *
from Demo.DimCustomerLarge
where nk_BusinessEntityID = 1
order by StartDate;
go
select * from demo.etlrun
go




use AdventureWorks2017test1;
go 


--Type 3 Change
update demo.PersonPhoneLarge
set PhoneNumber = '111-111-1111'
where BusinessEntityID = 1


use AdventureWorksDW2017test1
go 

select *
from Demo.DimCustomerLarge
where nk_BusinessEntityID = 1
order by StartDate;



select * from demo.etlrun
go





use AdventureWorks2017test1;
go 


--Type 1, 2, and 3 Change
update demo.PersonLarge
set Title = 'Mr', MiddleName = 'Calvin'
where [BusinessEntityID] = 1;

update demo.PersonPhoneLarge
set PhoneNumber = '222-222-2222'
where BusinessEntityID = 1;













use AdventureWorksDW2017test1
go 

select *
from Demo.DimCustomerLarge
where nk_BusinessEntityID = 1
order by StartDate;


select *
from Demo.etlrun