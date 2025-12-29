--Monitoring Inserted Data

USE E_Commerce;

SELECT * 
FROM core.CustomerSegment
--Done

SELECT *
FROM core.Customer
--Done

SELECT *
FROM core.CustomerContact

SELECT 
	MIN(CustomerID),
	MAX(CustomerID),
	COUNT(DISTINCT CustomerID),
	MIN(ContactID),
	MAX(ContactID),
	COUNT(DISTINCT ContactID)
FROM core.CustomerContact
--Done

SELECT 
	MIN(CustomerID),
	MAX(CustomerID),
	COUNT(DISTINCT CustomerID),
	MIN(AddressID),
	MAX(AddressID),
	COUNT(DISTINCT AddressID)
FROM core.CustomerAddress
--Done

SELECT * 
FROM core.CustomerLoginHistory;

SELECT 
	MIN(CustomerID),
	MAX(CustomerID),
	COUNT(DISTINCT CustomerID),
	MIN(LoginID),
	MAX(LoginID),
	COUNT(DISTINCT LoginID)
FROM core.CustomerLoginHistory;
--Done

SELECT *
FROM core.Seller
--Done

SELECT *
FROM core.SellerContract
--Done

SELECT *
FROM core.SellerAddress
--Done

SELECT *
FROM core.SellerRating;
--Done

SELECT *
FROM core.Seller

SELECT * 
FROM sales.Product

EXEC sp_who2;

DBCC OPENTRAN('E_Commerce');

KILL 60;

DELETE FROM sales.Product

DBCC CHECKIDENT ('sales.Product', RESEED, 0); --Reset identity to start from 1
--Done

SELECT *
FROM sales.ProductAttribute
--Done

SELECT *
FROM inventory.Inventory

SELECT *
FROM inventory.InventoryMovement

DBCC OPENTRAN('E_Commerce');

KILL 58;

DELETE FROM inventory.InventoryMovement

DBCC CHECKIDENT ('inventory.InventoryMovement', RESEED, 0);
--Done

SELECT *
FROM sales.[Order]
--Done

SELECT *
FROM sales.OrderStatusHistory
--Done

SELECT *
FROM sales.OrderItem
--Done

SELECT *
FROM logistics.ShipmentType
--Done

SELECT *
FROM logistics.Shipment
--Done

SELECT *
FROM payment.Payment
--Done

SELECT *
FROM payment.PaymentStatusHistory