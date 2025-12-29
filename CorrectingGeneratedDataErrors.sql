USE E_Commerce;




SELECT *
FROM core.Seller;
--I'll Update all Sellers in Seller table to be registerd from 2021.
--I assume that we have the contract with them before we start our business.
UPDATE core.Seller
SET RegistrationDate = 
	DATEADD(
			DAY,
			ABS(CHECKSUM(NEWID())) % 365,
			'2021-01-01'
			);

SELECT * 
FROM core.SellerContract sc
JOIN core.Seller s
	ON sc.SellerID = s.SellerID;
--The contract StartDate is the same as Seller RegistrationDate 
UPDATE sc
SET sc.StartDate = s.RegistrationDate
FROM core.SellerContract sc
JOIN core.Seller s
	ON sc.SellerID = s.SellerID;

SELECT *
FROM core.SellerContract;
--All Contracts life time is 5 years
UPDATE core.SellerContract
SET EndDate =
	DATEADD(
		YEAR,
		5,
		StartDate
	);

SELECT *
FROM sales.[Order];
--I'll set all orders to start from 2022 
--after all sellers are registerd
--I know it is a simple logic but i won't affect the analysis
UPDATE sales.[Order]
SET OrderDate =
	DATEADD(
		DAY,
		ABS(CHECKSUM(NEWID())) % DATEDIFF(DAY, '2022-01-01', GETDATE()),
		'2022-01-01'
	);

SELECT * 
FROM sales.OrderItem oi
JOIN sales.Product p
	ON oi.ProductID = p.ProductID;
--Updating unit price in OrderItem table to be the same as Price in Product table
UPDATE oi
SET UnitPrice = 
	p.CurrentPrice
FROM sales.OrderItem oi
JOIN sales.Product p
	ON oi.ProductID = p.ProductID;

SELECT *
FROM sales.[Order] o
JOIN sales.OrderItem oi
	ON o.OrderID = oi.OrderID;
--Updating column TotalAmount in Order table to equal sum (quantity * unitprice) in OrderItem table
UPDATE o
SET
	o.TotalAmount = sub.Total
FROM sales.[Order] o
JOIN(
	SELECT
		OrderID,
		SUM(Quantity * UnitPrice) AS Total
	FROM sales.OrderItem
	GROUP BY OrderID
	) sub
		ON o.OrderID = sub.OrderID;

SELECT *
FROM sales.OrderDiscount od
JOIN sales.[Order] o
	ON od.OrderID = o.OrderID
ORDER BY o.OrderID;
--Update TotalAmount in Order table by subtracting DiscountAmount from it
UPDATE o
SET o.TotalAmount =
	o.TotalAmount - od.DiscountAmount
FROM sales.OrderDiscount od
JOIN sales.[Order] o
	ON od.OrderID = o.OrderID;
--Bug found (TotalAmount is less than 0)

SELECT
    o.OrderID,
    o.TotalAmount AS OldTotal,
    od.DiscountAmount,
    o.TotalAmount - od.DiscountAmount AS NewTotal
FROM sales.[Order] o
JOIN sales.OrderDiscount od
    ON od.OrderID = o.OrderID
WHERE o.TotalAmount - od.DiscountAmount < 0;

--Handling it by setting the DiscountAmount to 0 where ToTalAmount - DiscountAmount is less than 100
UPDATE od
SET od.DiscountAmount = 0
FROM sales.[Order] o
JOIN sales.OrderDiscount od
    ON od.OrderID = o.OrderID
WHERE o.TotalAmount - od.DiscountAmount < 100;
--Then I Executed The previous Update Query (Total - Discount) again


SELECT *
FROM sales.OrderReturn orr
JOIN sales.OrderItem oi
	ON orr.OrderItemID = oi.OrderItemID
JOIN sales.[Order] o
	ON oi.OrderID = o.OrderID;

--Set ReturnDate in OrderReturn table to be 1 day after OrderDate
UPDATE orr
SET orr.ReturnDate = 
	DATEADD(
		DAY,
		1,
		o.OrderDate
	)
FROM sales.OrderReturn orr
JOIN sales.OrderItem oi
	ON orr.OrderItemID = oi.OrderItemID
JOIN sales.[Order] o
	ON oi.OrderID = o.OrderID;



SELECT *
FROM logistics.Shipment s
JOIN logistics.ShipmentType st
	ON s.ShipmentTypeID = st.ShipmentTypeID;

SELECT *
FROM sales.OrderStatusHistory ost
JOIN sales.[Order] o
	ON ost.OrderID = o.OrderID
WHERE ost.Status = 'Created'

--Order Creation Date is the same as OrderDate
UPDATE ost
SET ost.StatusDate = o.OrderDate
FROM sales.OrderStatusHistory ost
JOIN sales.[Order] o
	ON ost.OrderID = o.OrderID
WHERE ost.Status = 'Created'



--Purchase date is the same as order date for all orders
UPDATE osh
SET osh.StatusDate = o.OrderDate
FROM sales.OrderStatusHistory osh
JOIN sales.[Order] o
	ON osh.OrderID = o.OrderID
JOIN logistics.Shipment s
	ON o.OrderID = s.OrderID
JOIN logistics.ShipmentType st
	ON s.ShipmentTypeID = st.ShipmentTypeID
WHERE osh.Status = 'PAID';

--The next Updates logic is based on logistics.ShipmentType table
SELECT *
FROM logistics.ShipmentType;


--Same Day
UPDATE osh
SET osh.StatusDate = o.OrderDate
FROM sales.OrderStatusHistory osh
JOIN sales.[Order] o
	ON osh.OrderID = o.OrderID
JOIN logistics.Shipment s
	ON o.OrderID = s.OrderID
JOIN logistics.ShipmentType st
	ON s.ShipmentTypeID = st.ShipmentTypeID
WHERE osh.Status = 'SHIPPED'
AND st.Name = 'Same Day';

UPDATE osh
SET osh.StatusDate = 
	DATEADD(
		DAY,
		ABS(CHECKSUM(NEWID())) % 2,
		OrderDate
	)
FROM sales.OrderStatusHistory osh
JOIN sales.[Order] o
	ON osh.OrderID = o.OrderID
JOIN logistics.Shipment s
	ON o.OrderID = s.OrderID
JOIN logistics.ShipmentType st
	ON s.ShipmentTypeID = st.ShipmentTypeID
WHERE osh.Status = 'DELIVERED'
AND st.Name = 'Same Day';


--Express
UPDATE osh
SET osh.StatusDate =
    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 1 + 1,
        o.OrderDate
    )
FROM sales.OrderStatusHistory osh
JOIN sales.[Order] o
    ON osh.OrderID = o.OrderID
JOIN logistics.Shipment s
    ON o.OrderID = s.OrderID
JOIN logistics.ShipmentType st
    ON s.ShipmentTypeID = st.ShipmentTypeID
WHERE osh.Status = 'SHIPPED'
AND st.Name = 'Express';

UPDATE osh
SET osh.StatusDate =
    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 2 + 1,
        osh2.StatusDate
    )
FROM sales.OrderStatusHistory osh
JOIN sales.OrderStatusHistory osh2
	ON osh.OrderID = osh2.OrderID
JOIN sales.[Order] o
    ON osh.OrderID = o.OrderID
JOIN logistics.Shipment s
    ON o.OrderID = s.OrderID
JOIN logistics.ShipmentType st
    ON s.ShipmentTypeID = st.ShipmentTypeID
WHERE osh.Status = 'DELIVERED'
AND st.Name = 'Express'
AND osh2.Status = 'SHIPPED';


--Standard
UPDATE osh
SET osh.StatusDate =
    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 3 + 1,
        o.OrderDate
    )
FROM sales.OrderStatusHistory osh
JOIN sales.[Order] o
    ON osh.OrderID = o.OrderID
JOIN logistics.Shipment s
    ON o.OrderID = s.OrderID
JOIN logistics.ShipmentType st
    ON s.ShipmentTypeID = st.ShipmentTypeID
WHERE osh.Status = 'SHIPPED'
AND st.Name = 'Standard';

UPDATE osh
SET osh.StatusDate =
    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 4 + 1,
        osh2.StatusDate
    )
FROM sales.OrderStatusHistory osh
JOIN sales.OrderStatusHistory osh2
	ON osh.OrderID = osh2.OrderID
JOIN sales.[Order] o
    ON osh.OrderID = o.OrderID
JOIN logistics.Shipment s
    ON o.OrderID = s.OrderID
JOIN logistics.ShipmentType st
    ON s.ShipmentTypeID = st.ShipmentTypeID
WHERE osh.Status = 'DELIVERED'
AND st.Name = 'Standard'
AND osh2.Status = 'SHIPPED';


--Economy
UPDATE osh
SET osh.StatusDate =
    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 7 + 5,
        o.OrderDate
    )
FROM sales.OrderStatusHistory osh
JOIN sales.[Order] o
    ON osh.OrderID = o.OrderID
JOIN logistics.Shipment s
    ON o.OrderID = s.OrderID
JOIN logistics.ShipmentType st
    ON s.ShipmentTypeID = st.ShipmentTypeID
WHERE osh.Status = 'SHIPPED'
AND st.Name = 'Economy';

UPDATE osh
SET osh.StatusDate =
    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 7 + 5,
        osh2.StatusDate
    )
FROM sales.OrderStatusHistory osh
JOIN sales.OrderStatusHistory osh2
	ON osh.OrderID = osh2.OrderID
JOIN sales.[Order] o
    ON osh.OrderID = o.OrderID
JOIN logistics.Shipment s
    ON o.OrderID = s.OrderID
JOIN logistics.ShipmentType st
    ON s.ShipmentTypeID = st.ShipmentTypeID
WHERE osh.Status = 'DELIVERED'
AND st.Name = 'Economy'
AND osh2.Status = 'SHIPPED';


--Update Shipment & Delivery Dates in Shipment table based on the dates in OrderStatusHistory table
UPDATE s
SET s.ShipmentDate = osh.StatusDate
FROM logistics.Shipment s
JOIN sales.OrderStatusHistory osh
	ON s.OrderID = osh.OrderID
WHERE osh.Status = 'SHIPPED'

UPDATE s
SET s.DeliveryDate = osh.StatusDate
FROM logistics.Shipment s
JOIN sales.OrderStatusHistory osh
	ON s.OrderID = osh.OrderID
WHERE osh.Status = 'DELIVERED'

--Check
SELECT *
FROM logistics.Shipment s
JOIN sales.OrderStatusHistory osh
	ON s.OrderID = osh.OrderID
WHERE s.ShipmentDate > s.DeliveryDate
--Done

SELECT *
FROM sales.OrderStatusHistory o1
JOIN sales.OrderStatusHistory o2
	ON o1.OrderID = o2.OrderID
WHERE o1.Status = 'CREATED'
AND o2.Status = 'PAID'
AND o1.StatusDate = o2.StatusDate;

SELECT *
FROM sales.OrderStatusHistory o1
JOIN sales.OrderStatusHistory o2
	ON o1.OrderID = o2.OrderID
WHERE o1.Status = 'PAID'
AND o2.Status = 'SHIPPED'
AND o1.StatusDate > o2.StatusDate;

SELECT *
FROM sales.OrderStatusHistory o1
JOIN sales.OrderStatusHistory o2
	ON o1.OrderID = o2.OrderID
WHERE o1.Status = 'SHIPPED'
AND o2.Status = 'DELIVERED'
AND o1.StatusDate > o2.StatusDate;

