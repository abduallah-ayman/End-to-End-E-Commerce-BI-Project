USE ECommerce_DWH
GO

SET IDENTITY_INSERT dim.DimCustomer ON;

INSERT INTO dim.DimCustomer
(
    CustomerKey,
    CustomerID,
    FullName,
    Gender,
    DateOfBirth,
    SegmentName,
    ShipmentCity,
    ShipmentState,
    ShipmentCountry,
    Email,
    StartDate,
    EndDate,
    IsCurrent
)
VALUES
(
    -1,
    -1,
    'Unknown',
    'U',
    NULL,
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown',
    '1900-01-01',
    NULL,
    1
);

SET IDENTITY_INSERT dim.DimCustomer OFF;
GO

SET IDENTITY_INSERT dim.DimProduct ON;

INSERT INTO dim.DimProduct
(
    ProductKey,
    ProductID,
    ProductName,
    Category,
    SubCategory,
    CurrentPrice,
    StartDate,
    EndDate,
    IsCurrent
)
VALUES
(
    -1,
    -1,
    'Unknown',
    'Unknown',
    'Unknown',
    0,
    '1900-01-01',
    NULL,
    1
);

SET IDENTITY_INSERT dim.DimProduct OFF;
GO

SET IDENTITY_INSERT dim.DimSeller ON;

INSERT INTO dim.DimSeller
(
    SellerKey,
    SellerID,
    SellerName,
    Country,
	CommissionRate,
    StartDate,
    EndDate,
    IsCurrent
)
VALUES
(
    -1,                 -- Surrogate Key
    -1,                 -- Business Key
    'Unknown Seller',
    'Unknown',
	0,
    '1900-01-01',
    NULL,
    1
);

SET IDENTITY_INSERT dim.DimSeller OFF;
GO

INSERT INTO dim.DimDate
(
    DateKey,
    FullDate,
    Day,
    Month,
    MonthName,
    Quarter,
    Year,
    IsWeekend
)
VALUES
(
    -1,
    '1900-01-01',
    1,
    1,
    'Unknown',
    1,
    1900,
    0
);
GO

SET IDENTITY_INSERT dim.DimPaymentMethod ON;

INSERT INTO dim.DimPaymentMethod
(
    PaymentMethodKey,
    PaymentMethodID,
    MethodName
)
VALUES
(
    -1,
    -1,
    'Unknown Payment Method'
);

SET IDENTITY_INSERT dim.DimPaymentMethod OFF;
GO



SET IDENTITY_INSERT dim.DimShipmentType ON;

INSERT INTO dim.DimShipmentType
(
    ShipmentTypeKey,
    ShipmentTypeID,
    Name,
    AVGRate,
    MaxDaysToShip
)
VALUES
(
    -1,
    -1,
    'Unknown Shipment Type',
    NULL,
    NULL
);

SET IDENTITY_INSERT dim.DimShipmentType OFF;
GO

SET IDENTITY_INSERT dim.DimWarehouse ON;
GO

INSERT INTO dim.DimWarehouse
(
    WarehouseKey,
    WarehouseID,
    WarehouseName,
    City,
    Country
)
VALUES
(
    -1,
    -1,
    'Unknown Warehouse',
    'Unknown',
    'Unknown'
);
GO

SET IDENTITY_INSERT dim.DimWarehouse OFF;
GO

