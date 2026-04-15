CREATE DATABASE ECommerce_Staging;
GO


USE ECommerce_Staging;
GO

CREATE SCHEMA stg;
GO

--Customer Staging
CREATE TABLE stg.Customer (
    CustomerID     INT,
    FirstName      VARCHAR(255),
    LastName       VARCHAR(255),
    Gender         VARCHAR(10),
    DateOfBirth    DATE,
    SegmentID      INT,
    CreatedAt      DATETIME2,
    UpdatedAt      DATETIME2,

    LoadDate       DATETIME2 DEFAULT SYSDATETIME(),
    BatchID        INT,
    SourceSystem   VARCHAR(50)
);
GO

CREATE TABLE stg.CustomerAddress (
    AddressID     INT,
    CustomerID    INT,
    AddressType   VARCHAR(50),
    Street        VARCHAR(255),
    City          VARCHAR(100),
    State         VARCHAR(100),
    PostalCode    VARCHAR(50),
    Country       VARCHAR(100),

    LoadDate      DATETIME2 DEFAULT SYSDATETIME(),
    BatchID       INT,
    SourceSystem  VARCHAR(50)
);
GO

CREATE TABLE stg.CustomerContact (
    ContactID     INT,
    CustomerID    INT,
    Email         VARCHAR(255),
    Phone         VARCHAR(50),
    IsPrimary     BIT,

    LoadDate      DATETIME2 DEFAULT SYSDATETIME(),
    BatchID       INT,
    SourceSystem  VARCHAR(50)
);
GO


CREATE TABLE stg.CustomerSegment (
    SegmentID     INT,
    SegmentName   VARCHAR(100),

    LoadDate      DATETIME2 DEFAULT SYSDATETIME(),
    BatchID       INT,
    SourceSystem  VARCHAR(50)
);
GO


CREATE TABLE stg.CustomerLoginHistory (
    LoginID      INT,
    CustomerID   INT,
    LoginTime    DATETIME2,
    IPAddress    VARCHAR(50),

    LoadDate     DATETIME2 DEFAULT SYSDATETIME(),
    BatchID      INT,
    SourceSystem VARCHAR(50)
);
GO


--Seller Staging
CREATE TABLE stg.Seller (
    SellerID          INT,
    SellerName        VARCHAR(255),
    RegistrationDate  DATE,
    CreatedAt         DATETIME2,

    LoadDate          DATETIME2 DEFAULT SYSDATETIME(),
    BatchID           INT,
    SourceSystem      VARCHAR(50)
);
GO


CREATE TABLE stg.SellerContract (
    ContractID       INT,
    SellerID         INT,
    StartDate        DATE,
    EndDate          DATE,
    CommissionRate   DECIMAL(10,2),

    LoadDate         DATETIME2 DEFAULT SYSDATETIME(),
    BatchID          INT,
    SourceSystem     VARCHAR(50)
);
GO

CREATE TABLE stg.SellerAddress (
    SellerAddressID INT,
    SellerID        INT,
    Street          VARCHAR(255),
    City            VARCHAR(100),
    Country         VARCHAR(100),

    LoadDate        DATETIME2 DEFAULT SYSDATETIME(),
    BatchID         INT,
    SourceSystem    VARCHAR(50)
);
GO



--Product Staging
CREATE TABLE stg.Product (
    ProductID       INT,
    SellerID        INT,
    SubCategoryID   INT,
    ProductName     VARCHAR(255),
    CurrentPrice    DECIMAL(12,2),
    CreatedAt       DATETIME2,

    LoadDate        DATETIME2 DEFAULT SYSDATETIME(),
    BatchID         INT,
    SourceSystem    VARCHAR(50)
);
GO


CREATE TABLE stg.ProductAttribute (
    AttributeID     INT,
    ProductID       INT,
    AttributeName   VARCHAR(100),
    AttributeValue  VARCHAR(255),

    LoadDate        DATETIME2 DEFAULT SYSDATETIME(),
    BatchID         INT,
    SourceSystem    VARCHAR(50)
);
GO


CREATE TABLE stg.ProductCategory (
    CategoryID   INT,
    CategoryName VARCHAR(100),

    LoadDate     DATETIME2 DEFAULT SYSDATETIME(),
    BatchID      INT,
    SourceSystem VARCHAR(50)
);
GO


CREATE TABLE stg.ProductSubCategory (
    SubCategoryID   INT,
    CategoryID      INT,
    SubCategoryName VARCHAR(100),

    LoadDate        DATETIME2 DEFAULT SYSDATETIME(),
    BatchID         INT,
    SourceSystem    VARCHAR(50)
);
GO


--Inventory Staging
CREATE TABLE stg.Inventory (
    InventoryID        INT,
    ProductID          INT,
    WarehouseID        INT,
    QuantityAvailable  INT,

    LoadDate           DATETIME2 DEFAULT SYSDATETIME(),
    BatchID            INT,
    SourceSystem       VARCHAR(50)
);
GO

CREATE TABLE stg.Warehouse (
    WarehouseID    INT,
    WarehouseName  VARCHAR(100),
    City           VARCHAR(100),
    Country        VARCHAR(100),

    LoadDate       DATETIME2 DEFAULT SYSDATETIME(),
    BatchID        INT,
    SourceSystem   VARCHAR(50)
);
GO


CREATE TABLE stg.InventoryMovement (
    MovementID     INT,
    InventoryID    INT,
    QuantityChange INT,
    MovementType   VARCHAR(10),
    MovementDate   DATETIME2,

    LoadDate       DATETIME2 DEFAULT SYSDATETIME(),
    BatchID        INT,
    SourceSystem   VARCHAR(50)
);
GO


--Orders & Sales Staging
CREATE TABLE stg.[Order] (
    OrderID       INT,
    CustomerID    INT,
    OrderDate     DATETIME2,
    TotalAmount   DECIMAL(14,2),

    LoadDate      DATETIME2 DEFAULT SYSDATETIME(),
    BatchID       INT,
    SourceSystem  VARCHAR(50)
);
GO


CREATE TABLE stg.OrderItem (
    OrderItemID   INT,
    OrderID       INT,
    ProductID     INT,
    Quantity      INT,
    UnitPrice     DECIMAL(12,2),

    LoadDate      DATETIME2 DEFAULT SYSDATETIME(),
    BatchID       INT,
    SourceSystem  VARCHAR(50)
);
GO

CREATE TABLE stg.OrderDiscount (
    DiscountID      INT,
    OrderID         INT,
    DiscountAmount  DECIMAL(12,2),

    LoadDate        DATETIME2 DEFAULT SYSDATETIME(),
    BatchID         INT,
    SourceSystem    VARCHAR(50)
);
GO


CREATE TABLE stg.OrderStatusHistory (
    StatusHistoryID INT,
    OrderID         INT,
    Status          VARCHAR(30),
    StatusDate      DATETIME2,

    LoadDate        DATETIME2 DEFAULT SYSDATETIME(),
    BatchID         INT,
    SourceSystem    VARCHAR(50)
);
GO


CREATE TABLE stg.OrderReturn (
    ReturnID     INT,
    OrderItemID  INT,
    Reason       VARCHAR(255),
    ReturnDate   DATE,

    LoadDate     DATETIME2 DEFAULT SYSDATETIME(),
    BatchID      INT,
    SourceSystem VARCHAR(50)
);
GO


--Payment Staging
CREATE TABLE stg.Payment (
    PaymentID        INT,
    OrderID          INT,
    PaymentMethodID  INT,
    Amount           DECIMAL(14,2),
    PaymentDate      DATETIME2,

    LoadDate         DATETIME2 DEFAULT SYSDATETIME(),
    BatchID          INT,
    SourceSystem     VARCHAR(50)
);
GO

CREATE TABLE stg.PaymentMethod (
    PaymentMethodID INT,
    MethodName      VARCHAR(50),

    LoadDate        DATETIME2 DEFAULT SYSDATETIME(),
    BatchID         INT,
    SourceSystem    VARCHAR(50)
);
GO


--Shipment Staging
CREATE TABLE stg.Shipment (
    ShipmentID       INT,
    OrderID          INT,
    ShipmentTypeID   INT,
    DeliveryPartner  VARCHAR(255),
    ShipmentDate     DATE,
    DeliveryDate     DATE,
    Status           VARCHAR(50),
    CustomerRating   INT,

    LoadDate         DATETIME2 DEFAULT SYSDATETIME(),
    BatchID          INT,
    SourceSystem     VARCHAR(50)
);
GO


CREATE TABLE stg.ShipmentType (
    ShipmentTypeID  INT,
    Name            VARCHAR(50),
    AVGRate         INT,
    MaxDaysToShip   INT,

    LoadDate        DATETIME2 DEFAULT SYSDATETIME(),
    BatchID         INT,
    SourceSystem    VARCHAR(50)
);
GO


--Control Table for Last Modified Strategy
CREATE TABLE stg.ETL_LoadControl (
    TableName           VARCHAR(100) PRIMARY KEY,  
    
    LastSuccessfulLoad  DATETIME2 NULL,            
    
    LastLoadStartTime   DATETIME2 NULL,
    LastLoadEndTime     DATETIME2 NULL,
    
    LastLoadStatus      VARCHAR(20) NULL,          
    
    LastLoadRowCount    INT NULL,                 
    
    CreatedAt           DATETIME2 DEFAULT SYSDATETIME(),
    UpdatedAt           DATETIME2 NULL
);


CREATE TABLE stg.ETL_Batch (
    BatchID INT IDENTITY PRIMARY KEY,
    BatchStartTime DATETIME2,
    BatchEndTime DATETIME2,
    Status VARCHAR(20)
);