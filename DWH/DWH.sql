CREATE DATABASE ECommerce_DWH;
GO

USE ECommerce_DWH;
GO

CREATE SCHEMA dim;
GO
CREATE SCHEMA fact;
GO
CREATE SCHEMA ref
GO


CREATE TABLE dim.DimDate (
    DateKey INT NOT NULL PRIMARY KEY,      
    FullDate DATE NOT NULL,
    Day TINYINT,
    Month TINYINT,
    MonthName VARCHAR(20),
    Quarter TINYINT,
    Year SMALLINT,
    IsWeekend BIT
);
GO


CREATE TABLE dim.DimCustomer (
    CustomerKey INT IDENTITY PRIMARY KEY,
    CustomerID INT NOT NULL,               
    FullName VARCHAR(200),
    Gender CHAR(1),
    DateOfBirth DATE,
    SegmentName VARCHAR(50),
    ShipmentCity VARCHAR(100),
    ShipmentState VARCHAR(100),
    ShipmentCountry VARCHAR(100),
	Email VARCHAR(255),
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    IsCurrent BIT NOT NULL
);
GO


CREATE TABLE dim.DimProduct (
    ProductKey INT IDENTITY PRIMARY KEY,
    ProductID INT NOT NULL,                
    ProductName VARCHAR(200),
    Category VARCHAR(100),
    SubCategory VARCHAR(100),
	CurrentPrice DECIMAL, 
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    IsCurrent BIT NOT NULL
);
GO


CREATE TABLE dim.DimSeller (
    SellerKey INT IDENTITY PRIMARY KEY,
    SellerID INT NOT NULL,                 
    SellerName VARCHAR(200),
    Country VARCHAR(100),
    CommissionRate DECIMAL(5,2),
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    IsCurrent BIT NOT NULL
);
GO


CREATE TABLE dim.DimPaymentMethod (
    PaymentMethodKey INT IDENTITY PRIMARY KEY,
    PaymentMethodID INT NOT NULL,           
    MethodName VARCHAR(50)
);
GO


CREATE TABLE dim.DimShipmentType (
    ShipmentTypeKey INT IDENTITY PRIMARY KEY,
    ShipmentTypeID INT NOT NULL,            
    Name VARCHAR(30),
    AVGRate INT,
    MaxDaysToShip INT
);
GO


CREATE TABLE dim.DimWarehouse (
    WarehouseKey INT IDENTITY PRIMARY KEY,
    WarehouseID INT NOT NULL,              
    WarehouseName VARCHAR(100),
    City VARCHAR(100),
    Country VARCHAR(100)
);
GO


CREATE TABLE fact.FactSales (
    SalesKey BIGINT IDENTITY PRIMARY KEY,

    -- Degenerate Dimensions
    OrderID INT,
    OrderItemID INT,

    -- Dimension Keys
    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    SellerKey INT NOT NULL,
    DateKey INT NOT NULL,

    -- Measures
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    GrossAmount DECIMAL(12,2),
    DiscountAmount DECIMAL(12,2),
    NetAmount DECIMAL(12,2)
);
GO


CREATE TABLE fact.FactPayments (
    PaymentKey BIGINT IDENTITY PRIMARY KEY,

    -- Degenerate Dimensions
    PaymentID INT,
    OrderID INT,

    -- Dimension Keys
    CustomerKey INT,
    PaymentMethodKey INT,
    DateKey INT,

    -- Measures
    PaymentAmount DECIMAL(12,2)
);
GO


CREATE TABLE fact.FactShipment (
    ShipmentKey BIGINT IDENTITY PRIMARY KEY,

    -- Degenerate Dimensions
    ShipmentID INT,
    OrderID INT,

    -- Dimension Keys
	CustomerKey INT,
    ShipmentTypeKey INT,
    ShipmentDateKey INT,
    DeliveryDateKey INT,

    -- Measures
    ShippingDays INT,
    CustomerRating INT
);
GO


CREATE TABLE fact.FactInventorySnapshot (
    ProductKey INT NOT NULL,
    WarehouseKey INT NOT NULL,
    DateKey INT NOT NULL,
    QuantityAvailable INT,

    CONSTRAINT UQ_InventorySnapshot
        UNIQUE (ProductKey, WarehouseKey, DateKey)
);
GO


CREATE TABLE fact.FactCustomerLogin (
    LoginKey BIGINT IDENTITY PRIMARY KEY,

    -- Degenerate
    LoginID INT,

    -- Dimensions
    CustomerKey INT NOT NULL,
    DateKey INT NOT NULL,

    -- Attributes
    IPAddress VARCHAR(50)
);
GO

CREATE TABLE fact.FactInventoryMovement (
    MovementKey BIGINT IDENTITY PRIMARY KEY,

    -- Degenerate
    MovementID INT,

    -- Dimensions
    ProductKey INT NOT NULL,
    WarehouseKey INT NOT NULL,
    DateKey INT NOT NULL,

    -- Measures
    QuantityChange INT,
    MovementType VARCHAR(10)
);
GO

CREATE TABLE fact.FactOrderStatus (
    OrderStatusKey BIGINT IDENTITY PRIMARY KEY,

    -- Degenerate
    OrderID INT,

    -- Dimensions
    CustomerKey INT NOT NULL,
    DateKey INT NOT NULL,

    -- Attributes
    Status VARCHAR(30)
);


CREATE TABLE fact.FactReturns (
    ReturnKey BIGINT IDENTITY PRIMARY KEY,

    -- Degenerate
    ReturnID INT,
    OrderID INT,
    OrderItemID INT,

    -- Dimensions
    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    DateKey INT NOT NULL,

    -- Measures
    ReturnedQuantity INT DEFAULT 1,
    ReturnReason VARCHAR(255)
);
GO


DECLARE @StartDate DATE = '2010-01-01'
DECLARE @EndDate DATE = '2030-12-31'

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO dim.DimDate
    VALUES (
        YEAR(@StartDate)*10000 + MONTH(@StartDate)*100 + DAY(@StartDate),
        @StartDate,
        DAY(@StartDate),
        MONTH(@StartDate),
        DATENAME(MONTH,@StartDate),
        DATEPART(QUARTER,@StartDate),
        YEAR(@StartDate),
        CASE WHEN DATEPART(WEEKDAY,@StartDate) IN (1,7) THEN 1 ELSE 0 END
    )

    SET @StartDate = DATEADD(DAY,1,@StartDate)
END

