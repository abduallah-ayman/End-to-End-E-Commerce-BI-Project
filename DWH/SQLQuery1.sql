SELECT *
FROM dim.DimCustomer
WHERE CustomerID = 1;

SELECT *
FROM ctl.ETL_Batch;

SELECT *
FROM ctl.ETL_TableLoadControl;

TRUNCATE TABLE ctl.ETL_TableLoadControl

TRUNCATE TABLE dim.DimCustomer

TRUNCATE TABLE ctl.ETL_Batch



USE ECommerce_Staging;

SELECT *
FROM stg.Customer

SELECT
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS FullName,
    c.Gender,
    c.DateOfBirth,
    s.SegmentName,
    ca.City AS ShipmentCity,
    ca.State AS ShipmentState,
    ca.Country AS ShipmentCountry,
    cc.Email,
    c.UpdatedAt
FROM stg.Customer c
LEFT JOIN stg.CustomerSegment s
    ON c.SegmentID = s.SegmentID
LEFT JOIN stg.CustomerAddress ca
    ON c.CustomerID = ca.CustomerID
    AND ca.AddressType = 'Shipping'
LEFT JOIN stg.CustomerContact cc
    ON c.CustomerID = cc.CustomerID
    AND cc.IsPrimary = 1
WHERE c.UpdatedAt > '1900-01-01'
   OR c.CreatedAt > '1900-01-01'

SELECT *
FROM stg.Customer

UPDATE stg.Customer
SET FirstName = 'Abdullah'
WHERE CustomerID = 1

UPDATE stg.Customer
SET UpdatedAt = GETDATE()
WHERE CustomerID = 1


SELECT
	p.ProductID,
	p.ProductName,
	pc.CategoryName,
	psc.SubCategoryName,
	p.CurrentPrice
FROM stg.Product p
LEFT JOIN stg.ProductSubCategory psc
	ON p.SubCategoryID = psc.SubCategoryID
LEFT JOIN stg.ProductCategory pc
	ON psc.CategoryID = pc.CategoryID
WHERE p.CreatedAt > 

