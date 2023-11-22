--Create view that feeds DimProduct - this will be the OLEDB source in the dataflow

use AdventureWorks2017

create schema Demo

create or alter view Demo.vDimProduct as (

SELECT p.[ProductID] as nk_ProductID
      ,p.[ProductSubcategoryID] as nk_ProductSubcategoryID
	  ,sc.ProductCategoryID as nk_ProductCategoryID
      ,p.[Name] as ProductName
	  ,sc.Name as ProductSubCategory
	  ,c.name as ProductCategory
      ,p.[ProductNumber]      
      ,p.[Color]
      ,p.[ReorderPoint]
from production.Product p 
left join production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
left join production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
)

select * from demo.vDimProduct

create table demo.DimProduct 
(
	[pk_ProductKey] int not null identity(1,1) Primary key,
	[nk_ProductID] [int] NOT NULL,
	[nk_ProductSubCategoryID] [int] NULL,
	[nk_ProductCategoryID] [int] NULL,
	[ProductName] [nvarchar](50) NOT NULL,
	[ProductNumber] [nvarchar](25) NOT NULL,
	[Color] [nvarchar](15) NULL,
	[ReorderPoint] [smallint] NOT NULL,
	[ProductSubCategory] [nvarchar](50) NULL,
	[ProductCategory] [nvarchar](50) NULL,
	StartDate datetime NULL,
	EndDate datetime NULL,
	DateInserted datetime default getdate(),
	DateUpdated datetime default getdate()
) ON [PRIMARY] --> for assigning to the primary file group 

select * from demo.DimProduct
--------------------------------------------------------------------------

-- After creating the SCD1 Package let's test it by running these commands 

select *
from Demo.DimProduct



update Production.Product
set color = 'Gray'
where ProductID = 317



select *
from Demo.DimProduct
where nk_ProductID = 317




update Production.Product
set ReorderPoint = 350
where ProductID = 317




select *
from Demo.DimProduct
where nk_ProductID = 317



update Production.Product
set color = 'Black'
where ProductID = 317



select *
from Demo.DimProduct
where nk_ProductID = 317


--------------------------------------------------------------------------
--------------------------------------------------------------------------



























