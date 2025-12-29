DROP DATABASE IF EXISTS E_Commerce ;
GO

CREATE DATABASE E_Commerce;
GO
--DataBase
USE E_Commerce;
GO

--Schemas
CREATE SCHEMA core;
GO
CREATE SCHEMA ref;
GO
CREATE SCHEMA sales;
GO
CREATE SCHEMA inventory;
GO
CREATE SCHEMA payment;
GO
CREATE SCHEMA logistics;
GO

--Tables

--Customer
CREATE TABLE core.CustomerSegment(
	SegmentID INT IDENTITY PRIMARY KEY,
	SegmentName VARCHAR(50) NOT NULL UNIQUE 
);
GO

CREATE TABLE core.Customer (
    CustomerID INT IDENTITY PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
	Gender VARCHAR(1) NOT NULL CHECK(Gender IN ('M', 'F')),
    DateOfBirth DATE NULL,
    SegmentID INT NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,

    CONSTRAINT FK_Customer_Segment
        FOREIGN KEY (SegmentID)
        REFERENCES core.CustomerSegment(SegmentID)
);
GO

CREATE TABLE core.CustomerAddress (
    AddressID INT IDENTITY PRIMARY KEY,
    CustomerID INT NOT NULL,
    AddressType VARCHAR(20) NOT NULL CHECK (AddressType IN ('Billing','Shipping')),
    Street VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100) NOT NULL,

    CONSTRAINT FK_CustomerAddress_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES core.Customer(CustomerID)
        ON DELETE CASCADE
);
GO

CREATE TABLE core.CustomerContact (
    ContactID INT IDENTITY PRIMARY KEY,
    CustomerID INT NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(30),
    IsPrimary BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_CustomerContact_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES core.Customer(CustomerID)
        ON DELETE CASCADE
);
GO

CREATE TABLE core.CustomerLoginHistory (
    LoginID INT IDENTITY PRIMARY KEY,
    CustomerID INT NOT NULL,
    LoginTime DATETIME2 NOT NULL,
    IPAddress VARCHAR(50),

    CONSTRAINT FK_LoginHistory_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES core.Customer(CustomerID)
);
GO

--Seller
CREATE TABLE core.Seller (
    SellerID INT IDENTITY PRIMARY KEY,
    SellerName VARCHAR(200) NOT NULL,
    RegistrationDate DATE NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE core.SellerAddress (
    SellerAddressID INT IDENTITY PRIMARY KEY,
    SellerID INT NOT NULL,
    Street VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    Country VARCHAR(100) NOT NULL,

    CONSTRAINT FK_SellerAddress_Seller
        FOREIGN KEY (SellerID)
        REFERENCES core.Seller(SellerID)
        ON DELETE CASCADE
);
GO

CREATE TABLE core.SellerContract (
    ContractID INT IDENTITY PRIMARY KEY,
    SellerID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    CommissionRate DECIMAL(5,2) NOT NULL CHECK (CommissionRate BETWEEN 0 AND 100),

    CONSTRAINT FK_SellerContract_Seller
        FOREIGN KEY (SellerID)
        REFERENCES core.Seller(SellerID)
);
GO

CREATE TABLE core.SellerRating (
    RatingID INT IDENTITY PRIMARY KEY,
    SellerID INT NOT NULL,
    CustomerID INT NOT NULL,
    Rating TINYINT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    ReviewDate DATE NOT NULL,

    CONSTRAINT FK_SellerRating_Seller
        FOREIGN KEY (SellerID)
        REFERENCES core.Seller(SellerID),
    CONSTRAINT FK_SellerRating_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES core.Customer(CustomerID)
);
GO

--Product
CREATE TABLE ref.ProductCategory (
    CategoryID INT IDENTITY PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);
GO

CREATE TABLE ref.ProductSubCategory (
    SubCategoryID INT IDENTITY PRIMARY KEY,
    CategoryID INT NOT NULL,
    SubCategoryName VARCHAR(100) NOT NULL,

    CONSTRAINT FK_SubCategory_Category
        FOREIGN KEY (CategoryID)
        REFERENCES ref.ProductCategory(CategoryID)
);
GO

CREATE TABLE sales.Product (
    ProductID INT IDENTITY PRIMARY KEY,
    SellerID INT NOT NULL,
    SubCategoryID INT NOT NULL,
    ProductName VARCHAR(200) NOT NULL,
    CurrentPrice DECIMAL(10,2) NOT NULL CHECK (CurrentPrice > 0),
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Product_Seller
        FOREIGN KEY (SellerID)
        REFERENCES core.Seller(SellerID),
    CONSTRAINT FK_Product_SubCategory
        FOREIGN KEY (SubCategoryID)
        REFERENCES ref.ProductSubCategory(SubCategoryID)
);
GO

/*CREATE TABLE sales.ProductPriceHistory (
    PriceHistoryID INT IDENTITY PRIMARY KEY,
    ProductID INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,

    CONSTRAINT FK_PriceHistory_Product
        FOREIGN KEY (ProductID)
        REFERENCES sales.Product(ProductID)
);
GO*/

CREATE TABLE sales.ProductAttribute (
    AttributeID INT IDENTITY PRIMARY KEY,
    ProductID INT NOT NULL,
    AttributeName VARCHAR(100) NOT NULL,
    AttributeValue VARCHAR(200) NOT NULL,

    CONSTRAINT FK_ProductAttribute_Product
        FOREIGN KEY (ProductID)
        REFERENCES sales.Product(ProductID)
);
GO

--Inventory
CREATE TABLE inventory.Warehouse (
    WarehouseID INT IDENTITY PRIMARY KEY,
    WarehouseName VARCHAR(100) NOT NULL,
    City VARCHAR(100),
    Country VARCHAR(100)
);
GO

CREATE TABLE inventory.Inventory (
    InventoryID INT IDENTITY PRIMARY KEY,
    ProductID INT NOT NULL,
    WarehouseID INT NOT NULL,
    QuantityAvailable INT NOT NULL CHECK (QuantityAvailable >= 0),

    CONSTRAINT FK_Inventory_Product
        FOREIGN KEY (ProductID)
        REFERENCES sales.Product(ProductID),
    CONSTRAINT FK_Inventory_Warehouse
        FOREIGN KEY (WarehouseID)
        REFERENCES inventory.Warehouse(WarehouseID),

    CONSTRAINT UQ_Product_Warehouse UNIQUE (ProductID, WarehouseID)
);
GO

CREATE TABLE inventory.InventoryMovement (
    MovementID INT IDENTITY PRIMARY KEY,
    InventoryID INT NOT NULL,
    QuantityChange INT NOT NULL,
    MovementType VARCHAR(10) NOT NULL CHECK (MovementType IN ('IN','OUT')),
    MovementDate DATETIME2 NOT NULL,

    CONSTRAINT FK_InventoryMovement_Inventory
        FOREIGN KEY (InventoryID)
        REFERENCES inventory.Inventory(InventoryID)
);
GO

--Order
CREATE TABLE sales.[Order] (
    OrderID INT IDENTITY PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME2 NOT NULL,
    TotalAmount DECIMAL(12,2) NOT NULL CHECK (TotalAmount >= 0),

    CONSTRAINT FK_Order_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES core.Customer(CustomerID)
);
GO

CREATE TABLE sales.OrderItem (
    OrderItemID INT IDENTITY PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_OrderItem_Order
        FOREIGN KEY (OrderID)
        REFERENCES sales.[Order](OrderID)
        ON DELETE CASCADE,
    CONSTRAINT FK_OrderItem_Product
        FOREIGN KEY (ProductID)
        REFERENCES sales.Product(ProductID)
);
GO

CREATE TABLE sales.OrderStatusHistory (
    StatusHistoryID INT IDENTITY PRIMARY KEY,
    OrderID INT NOT NULL,
    Status VARCHAR(30) NOT NULL,
    StatusDate DATETIME2 NOT NULL,

    CONSTRAINT FK_OrderStatus_Order
        FOREIGN KEY (OrderID)
        REFERENCES sales.[Order](OrderID)
);
GO

CREATE TABLE sales.OrderReturn (
    ReturnID INT IDENTITY PRIMARY KEY,
    OrderItemID INT NOT NULL,
    Reason VARCHAR(255),
    ReturnDate DATE NOT NULL,

    CONSTRAINT FK_OrderReturn_Item
        FOREIGN KEY (OrderItemID)
        REFERENCES sales.OrderItem(OrderItemID)
);
GO

CREATE TABLE sales.OrderDiscount (
    DiscountID INT IDENTITY PRIMARY KEY,
    OrderID INT NOT NULL,
    DiscountAmount DECIMAL(10,2) NOT NULL CHECK (DiscountAmount >= 0),

    CONSTRAINT FK_OrderDiscount_Order
        FOREIGN KEY (OrderID)
        REFERENCES sales.[Order](OrderID)
);
GO

--Payment
CREATE TABLE payment.PaymentMethod (
    PaymentMethodID INT IDENTITY PRIMARY KEY,
    MethodName VARCHAR(50) NOT NULL UNIQUE
);
GO

CREATE TABLE payment.Payment (
    PaymentID INT IDENTITY PRIMARY KEY,
    OrderID INT NOT NULL,
    PaymentMethodID INT NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    PaymentDate DATETIME2 NOT NULL,

    CONSTRAINT FK_Payment_Order
        FOREIGN KEY (OrderID)
        REFERENCES sales.[Order](OrderID),
    CONSTRAINT FK_Payment_Method
        FOREIGN KEY (PaymentMethodID)
        REFERENCES payment.PaymentMethod(PaymentMethodID)
);
GO

CREATE TABLE payment.PaymentStatusHistory (
    PaymentStatusID INT IDENTITY PRIMARY KEY,
    PaymentID INT NOT NULL,
    Status VARCHAR(30) NOT NULL,
    StatusDate DATETIME2 NOT NULL,

    CONSTRAINT FK_PaymentStatus_Payment
        FOREIGN KEY (PaymentID)
        REFERENCES payment.Payment(PaymentID)
);
GO

--Logistics
CREATE TABLE logistics.ShipmentType(
	ShipmentTypeID INT IDENTITY PRIMARY KEY,
	Name VARCHAR(30) NOT NULL UNIQUE,
	AVGRate INT NOT NULL CHECK (AVGRate BETWEEN 1 AND 5),
	MaxDaysToShip INT CHECK (MaxDaysToShip >= 0)
);
GO

CREATE TABLE logistics.Shipment (
    ShipmentID INT IDENTITY PRIMARY KEY,
    OrderID INT NOT NULL,
	ShipmentTypeID INT NOT NULL,
    DeliveryPartner VARCHAR(100),
    ShipmentDate DATE NOT NULL,
    DeliveryDate DATE,
    Status VARCHAR(30) CHECK (Status IN ('Pending','Shipped','In Transit','Delivered','Cancelled')),
	CustomerRating INT NOT NULL CHECK (CustomerRating BETWEEN 1 AND 5),
    CONSTRAINT FK_Shipment_Order
        FOREIGN KEY (OrderID)
        REFERENCES sales.[Order](OrderID),
	CONSTRAINT FK_Shipment_ShipmentType
		FOREIGN KEY (ShipmentTypeID)
		REFERENCES logistics.ShipmentType(ShipmentTypeID)
);
