USE ECommerce_DWH;
GO

--Date Dimension
ALTER TABLE fact.FactSales
WITH CHECK
ADD CONSTRAINT FK_FactSales_DimDate
FOREIGN KEY (DateKey)
REFERENCES dim.DimDate(DateKey);
GO

ALTER TABLE fact.FactPayments
WITH CHECK
ADD CONSTRAINT FK_FactPayments_DimDate
FOREIGN KEY (DateKey)
REFERENCES dim.DimDate(DateKey);
GO

ALTER TABLE fact.FactShipment
WITH CHECK
ADD CONSTRAINT FK_FactShipment_ShipmentDate
FOREIGN KEY (ShipmentDateKey)
REFERENCES dim.DimDate(DateKey);
GO

ALTER TABLE fact.FactShipment
WITH CHECK
ADD CONSTRAINT FK_FactShipment_DeliveryDate
FOREIGN KEY (DeliveryDateKey)
REFERENCES dim.DimDate(DateKey);
GO


--FactSales
ALTER TABLE fact.FactSales
WITH CHECK
ADD CONSTRAINT FK_FactSales_Customer
FOREIGN KEY (CustomerKey)
REFERENCES dim.DimCustomer(CustomerKey);
GO

ALTER TABLE fact.FactSales
WITH CHECK
ADD CONSTRAINT FK_FactSales_Product
FOREIGN KEY (ProductKey)
REFERENCES dim.DimProduct(ProductKey);
GO

ALTER TABLE fact.FactSales
WITH CHECK
ADD CONSTRAINT FK_FactSales_Seller
FOREIGN KEY (SellerKey)
REFERENCES dim.DimSeller(SellerKey);
GO

--FactPayments
ALTER TABLE fact.FactPayments
WITH CHECK
ADD CONSTRAINT FK_FactPayments_Customer
FOREIGN KEY (CustomerKey)
REFERENCES dim.DimCustomer(CustomerKey);
GO

ALTER TABLE fact.FactPayments
WITH CHECK
ADD CONSTRAINT FK_FactPayments_PaymentMethod
FOREIGN KEY (PaymentMethodKey)
REFERENCES dim.DimPaymentMethod(PaymentMethodKey);
GO

--FactShipment
ALTER TABLE fact.FactShipment
WITH CHECK
ADD CONSTRAINT FK_FactShipment_Customer
FOREIGN KEY (CustomerKey)
REFERENCES dim.DimCustomer(CustomerKey);
GO

ALTER TABLE fact.FactShipment
WITH CHECK
ADD CONSTRAINT FK_FactShipment_ShipmentType
FOREIGN KEY (ShipmentTypeKey)
REFERENCES dim.DimShipmentType(ShipmentTypeKey);
GO


--FactInventorySnapshot
ALTER TABLE fact.FactInventorySnapshot
WITH CHECK
ADD CONSTRAINT FK_InventorySnapshot_Product
FOREIGN KEY (ProductKey)
REFERENCES dim.DimProduct(ProductKey);
GO

ALTER TABLE fact.FactInventorySnapshot
WITH CHECK
ADD CONSTRAINT FK_InventorySnapshot_Warehouse
FOREIGN KEY (WarehouseKey)
REFERENCES dim.DimWarehouse(WarehouseKey);
GO

ALTER TABLE fact.FactInventorySnapshot
WITH CHECK
ADD CONSTRAINT FK_InventorySnapshot_Date
FOREIGN KEY (DateKey)
REFERENCES dim.DimDate(DateKey);
GO

--FactReturns
ALTER TABLE fact.FactReturns
WITH CHECK
ADD CONSTRAINT FK_FactReturns_Customer
FOREIGN KEY (CustomerKey)
REFERENCES dim.DimCustomer(CustomerKey);
GO

ALTER TABLE fact.FactReturns
WITH CHECK
ADD CONSTRAINT FK_FactReturns_Product
FOREIGN KEY (ProductKey)
REFERENCES dim.DimProduct(ProductKey);
GO

ALTER TABLE fact.FactReturns
WITH CHECK
ADD CONSTRAINT FK_FactReturns_Date
FOREIGN KEY (DateKey)
REFERENCES dim.DimDate(DateKey);
GO

--FactCustomerLogin
ALTER TABLE fact.FactCustomerLogin
WITH CHECK
ADD CONSTRAINT FK_FactCustomerLogin_Customer
FOREIGN KEY (CustomerKey)
REFERENCES dim.DimCustomer(CustomerKey);
GO

ALTER TABLE fact.FactCustomerLogin
WITH CHECK
ADD CONSTRAINT FK_FactCustomerLogin_Date
FOREIGN KEY (DateKey)
REFERENCES dim.DimDate(DateKey);
GO

--FactInventoryMovement
ALTER TABLE fact.FactInventoryMovement
WITH CHECK
ADD CONSTRAINT FK_FactInventoryMovement_Product
FOREIGN KEY (ProductKey)
REFERENCES dim.DimProduct(ProductKey);
GO

ALTER TABLE fact.FactInventoryMovement
WITH CHECK
ADD CONSTRAINT FK_FactInventoryMovement_Warehouse
FOREIGN KEY (WarehouseKey)
REFERENCES dim.DimWarehouse(WarehouseKey);
GO

ALTER TABLE fact.FactInventoryMovement
WITH CHECK
ADD CONSTRAINT FK_FactInventoryMovement_Date
FOREIGN KEY (DateKey)
REFERENCES dim.DimDate(DateKey);
GO

--FactOrderStatus
ALTER TABLE fact.FactOrderStatus
WITH CHECK
ADD CONSTRAINT FK_FactOrderStatus_Customer
FOREIGN KEY (CustomerKey)
REFERENCES dim.DimCustomer(CustomerKey);
GO

ALTER TABLE fact.FactOrderStatus
WITH CHECK
ADD CONSTRAINT FK_FactOrderStatus_Date
FOREIGN KEY (DateKey)
REFERENCES dim.DimDate(DateKey);
GO


/*
Recommended final ETL order (perfect answer in interviews)

Load DimDate

Load other dimensions

Load facts

Run data quality checks

Enable FKs WITH CHECK

Fix any failures

Re-run FK script
*/

--This is for the first (full load)
--but for each next incremental load we will keep FKs enabled