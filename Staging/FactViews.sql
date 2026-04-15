USE ECommerce_Staging;
GO

CREATE OR ALTER VIEW stg.vw_FactSalesSource
AS
SELECT
    oi.OrderItemID,
    o.OrderID,
    o.CustomerID,
    p.ProductID,
    p.SellerID,
    CAST(o.OrderDate AS DATE) AS OrderDate,
    
    oi.Quantity,
    oi.UnitPrice,

    -- Measures
    oi.Quantity * oi.UnitPrice AS GrossAmount,
    ISNULL(d.DiscountAmount, 0) AS DiscountAmount,
    (oi.Quantity * oi.UnitPrice) - ISNULL(d.DiscountAmount, 0) AS NetAmount,

    -- Incremental Column
    o.LoadDate

FROM stg.[Order] o
JOIN stg.OrderItem oi 
    ON o.OrderID = oi.OrderID
JOIN stg.Product p 
    ON oi.ProductID = p.ProductID
LEFT JOIN stg.OrderDiscount d 
    ON o.OrderID = d.OrderID;
GO


CREATE OR ALTER VIEW stg.vw_FactPayment
AS
SELECT
	p.PaymentID,
	p.OrderID,
	o.CustomerID,
	p.PaymentMethodID,
	CAST(p.PaymentDate AS DATE) AS PaymentDate,
	p.Amount,
	p.LoadDate
FROM stg.Payment p
JOIN stg.[Order] o
	ON p.OrderID = o.OrderID;
GO


CREATE OR ALTER VIEW stg.vw_FactShipment
AS
SELECT
	s.ShipmentID,
	s.OrderID,
	o.CustomerID,
	s.ShipmentTypeID,
	CAST(s.ShipmentDate AS DATE) AS ShipmentDate,
	CAST(s.DeliveryDate AS DATE) AS DeliveryDate,
	DATEDIFF(DAY, s.ShipmentDate, s.DeliveryDate) AS ShippingDays,
	s.CustomerRating,
	s.LoadDate
FROM stg.Shipment s
JOIN stg.[Order] o
	ON s.OrderID = o.OrderID;
GO


CREATE OR ALTER VIEW stg.vw_InventorySnapshot_Load
AS
SELECT
    i.ProductID,
    i.WarehouseID,
    i.QuantityAvailable
FROM stg.Inventory i;
GO


CREATE OR ALTER VIEW stg.vw_FactReturns
AS
SELECT
	ReturnID,
	i.OrderID,
	r.OrderItemID,
	o.CustomerID,
	i.ProductID,
	CAST(r.ReturnDate AS DATE) AS ReturnDate,
	r.Reason,
	i.Quantity,
	r.LoadDate
FROM stg.OrderReturn r
JOIN stg.OrderItem i
	ON r.OrderItemID = i.OrderItemID
JOIN stg.[Order] o
	ON i.OrderID = o.OrderID;


