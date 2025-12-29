USE E_Commerce;
GO

--Every Foreign Key should have a supporting NONCLUSTERED index
--SQL Server does NOT auto-create indexes on FKs.

--Without them:
	--Joins are slow
	--Deletes/updates cause blocking
	--Execution plans use table scans


--CORE SCHEMA INDEXES

--Customer
-- FK lookup (Segment ? Customers)
CREATE NONCLUSTERED INDEX IX_Customer_SegmentID
ON core.Customer(SegmentID);
GO

-- Frequent customer lookups (email-based joins)
CREATE NONCLUSTERED INDEX IX_CustomerContact_CustomerID
ON core.CustomerContact(CustomerID);
GO

-- Login history analysis (customer + date)
CREATE NONCLUSTERED INDEX IX_CustomerLoginHistory_CustomerID_LoginTime
ON core.CustomerLoginHistory(CustomerID, LoginTime DESC);
GO

-- Address lookups (customer profile page)
CREATE NONCLUSTERED INDEX IX_CustomerAddress_CustomerID
ON core.CustomerAddress(CustomerID);
GO

--Seller
CREATE NONCLUSTERED INDEX IX_SellerAddress_SellerID
ON core.SellerAddress(SellerID);
GO

CREATE NONCLUSTERED INDEX IX_SellerContract_SellerID
ON core.SellerContract(SellerID);
GO

CREATE NONCLUSTERED INDEX IX_SellerRating_SellerID
ON core.SellerRating(SellerID);
GO

CREATE NONCLUSTERED INDEX IX_SellerRating_CustomerID
ON core.SellerRating(CustomerID);
GO

--Categories & Products
CREATE NONCLUSTERED INDEX IX_ProductSubCategory_CategoryID
ON ref.ProductSubCategory(CategoryID);
GO

CREATE NONCLUSTERED INDEX IX_Product_SellerID
ON sales.Product(SellerID);
GO

CREATE NONCLUSTERED INDEX IX_Product_SubCategoryID
ON sales.Product(SubCategoryID);
GO

CREATE NONCLUSTERED INDEX IX_ProductAttribute_ProductID
ON sales.ProductAttribute(ProductID);
GO

--Search optimization: ex
CREATE NONCLUSTERED INDEX IX_Product_ProductName
ON sales.Product(ProductName);
GO

--INVENTORY
CREATE NONCLUSTERED INDEX IX_Inventory_ProductID
ON inventory.Inventory(ProductID);
GO

CREATE NONCLUSTERED INDEX IX_Inventory_WarehouseID
ON inventory.Inventory(WarehouseID);
GO

CREATE NONCLUSTERED INDEX IX_InventoryMovement_InventoryID_MovementDate
ON inventory.InventoryMovement(InventoryID, MovementDate DESC);
GO

--I will not make this index bec. its cardinality is so low
--CREATE NONCLUSTERED INDEX IX_InventoryMovement_MovementType
--ON inventory.InventoryMovement(MovementType);
--GO

CREATE NONCLUSTERED INDEX IX_Order_CustomerID
ON sales.[Order](CustomerID);
GO

CREATE NONCLUSTERED INDEX IX_Order_OrderDate
ON sales.[Order](OrderDate DESC);
GO

--Composite indexes replace single column indexes only when the single column is the LEFTMOST column.
--Also this one wins when filtering by both (customer & date)
--but it cant replace the date idx
--CREATE NONCLUSTERED INDEX IX_Order_CustomerID_OrderDate
--ON sales.[Order](CustomerID, OrderDate DESC);
--GO 

--Order Items
--Replaced by IX_OrderItem_OrderID_Cover so NotNeeded
--CREATE NONCLUSTERED INDEX IX_OrderItem_OrderID
--ON sales.OrderItem(OrderID);
--GO

CREATE NONCLUSTERED INDEX IX_OrderItem_ProductID
ON sales.OrderItem(ProductID);
GO

--Covering index
CREATE NONCLUSTERED INDEX IX_OrderItem_OrderID_Cover
ON sales.OrderItem(OrderID)
INCLUDE (ProductID, Quantity, UnitPrice);
GO

--Order Status History
CREATE NONCLUSTERED INDEX IX_OrderStatusHistory_OrderID_StatusDate
ON sales.OrderStatusHistory(OrderID, StatusDate DESC);
GO

CREATE NONCLUSTERED INDEX IX_OrderStatusHistory_Status
ON sales.OrderStatusHistory(Status);
GO

--Returns & Discounts
CREATE NONCLUSTERED INDEX IX_OrderReturn_OrderItemID
ON sales.OrderReturn(OrderItemID);
GO

CREATE NONCLUSTERED INDEX IX_OrderDiscount_OrderID
ON sales.OrderDiscount(OrderID);
GO

--PAYMENT INDEXES
CREATE NONCLUSTERED INDEX IX_Payment_OrderID
ON payment.Payment(OrderID);
GO

CREATE NONCLUSTERED INDEX IX_Payment_PaymentMethodID
ON payment.Payment(PaymentMethodID);
GO

CREATE NONCLUSTERED INDEX IX_Payment_PaymentDate
ON payment.Payment(PaymentDate DESC);
GO

CREATE NONCLUSTERED INDEX IX_PaymentStatusHistory_PaymentID_StatusDate
ON payment.PaymentStatusHistory(PaymentID, StatusDate DESC);
GO

--LOGISTICS INDEXES
CREATE NONCLUSTERED INDEX IX_Shipment_OrderID
ON logistics.Shipment(OrderID);
GO

CREATE NONCLUSTERED INDEX IX_Shipment_ShipmentTypeID
ON logistics.Shipment(ShipmentTypeID);
GO

CREATE NONCLUSTERED INDEX IX_Shipment_Status
ON logistics.Shipment(Status);
GO

CREATE NONCLUSTERED INDEX IX_Shipment_ShipmentDate
ON logistics.Shipment(ShipmentDate DESC);
GO

CREATE NONCLUSTERED INDEX IX_Shipment_DeliveryDate
ON logistics.Shipment(DeliveryDate);
GO

--I'll Create covering indexes on the datawarehouse bec. it will be used in reporting