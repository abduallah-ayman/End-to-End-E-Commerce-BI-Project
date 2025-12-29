USE E_Commerce;
GO

CREATE OR ALTER PROCEDURE core.usp_CreateCustomer
    @FirstName VARCHAR(100),
    @LastName VARCHAR(100),
    @Gender CHAR(1),
    @DateOfBirth DATE,
    @SegmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM core.CustomerSegment
            WHERE SegmentID = @SegmentID
        )
            THROW 50001, 'Invalid SegmentID.', 1;

        INSERT INTO core.Customer
        (FirstName, LastName, Gender, DateOfBirth, SegmentID)
        VALUES
        (@FirstName, @LastName, @Gender, @DateOfBirth, @SegmentID);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE core.usp_GetCustomerByID
    @CustomerID INT
AS
BEGIN
    SELECT *
    FROM core.Customer
    WHERE CustomerID = @CustomerID;
END;
GO

CREATE OR ALTER PROCEDURE core.usp_UpdateCustomer
    @CustomerID INT,
    @FirstName VARCHAR(100),
    @LastName VARCHAR(100),
    @SegmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 FROM core.Customer WHERE CustomerID = @CustomerID
        )
            THROW 50002, 'Customer not found.', 1;

        UPDATE core.Customer
        SET FirstName = @FirstName,
            LastName = @LastName,
            SegmentID = @SegmentID,
            UpdatedAt = SYSDATETIME()
        WHERE CustomerID = @CustomerID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO


--Used When the customer is wrongly inserted (has no FK in any table)
CREATE OR ALTER PROCEDURE core.usp_DeleteCustomer
    @CustomerID INT
AS
BEGIN
    DELETE FROM core.Customer
    WHERE CustomerID = @CustomerID;
END;
GO

CREATE OR ALTER PROCEDURE core.usp_AddCustomerAddress
    @CustomerID INT,
    @AddressType VARCHAR(20),
    @Street VARCHAR(255),
    @City VARCHAR(100),
    @Country VARCHAR(100)
AS
BEGIN
    INSERT INTO core.CustomerAddress
    (CustomerID, AddressType, Street, City, Country)
    VALUES
    (@CustomerID, @AddressType, @Street, @City, @Country);
END;
GO

CREATE OR ALTER PROCEDURE core.usp_GetCustomerAddresses
    @CustomerID INT
AS
BEGIN
    SELECT *
    FROM core.CustomerAddress
    WHERE CustomerID = @CustomerID;
END;
GO

CREATE OR ALTER PROCEDURE core.usp_UpdateCustomerAddress
    @AddressID INT,
    @Street VARCHAR(255),
    @City VARCHAR(100)
AS
BEGIN
    UPDATE core.CustomerAddress
    SET Street = @Street,
        City = @City
    WHERE AddressID = @AddressID;
END;
GO

CREATE OR ALTER PROCEDURE core.usp_DeleteCustomerAddress
    @AddressID INT
AS
BEGIN
    DELETE FROM core.CustomerAddress
    WHERE AddressID = @AddressID;
END;
GO

CREATE OR ALTER PROCEDURE core.usp_CreateSeller
    @SellerName VARCHAR(200),
    @RegistrationDate DATE
AS
BEGIN
    INSERT INTO core.Seller
    (SellerName, RegistrationDate)
    VALUES
    (@SellerName, @RegistrationDate);
END;
GO

CREATE OR ALTER PROCEDURE core.usp_GetSellerByID
    @SellerID INT
AS
BEGIN
    SELECT *
    FROM core.Seller
    WHERE SellerID = @SellerID;
END;
GO

CREATE OR ALTER PROCEDURE core.usp_UpdateSeller
    @SellerID INT,
    @SellerName VARCHAR(200)
AS
BEGIN
    UPDATE core.Seller
    SET SellerName = @SellerName
    WHERE SellerID = @SellerID;
END;
GO

CREATE OR ALTER PROCEDURE core.usp_DeleteSeller
    @SellerID INT
AS
BEGIN
    DELETE FROM core.Seller
    WHERE SellerID = @SellerID;
END;
GO



CREATE OR ALTER PROCEDURE ref.usp_CreateProductCategory
    @CategoryName VARCHAR(100)
AS
BEGIN
    INSERT INTO ref.ProductCategory (CategoryName)
    VALUES (@CategoryName);
END;
GO

CREATE OR ALTER PROCEDURE ref.usp_GetProductCategories
AS
BEGIN
    SELECT * FROM ref.ProductCategory;
END;
GO

CREATE OR ALTER PROCEDURE sales.usp_CreateProduct
    @SellerID INT,
    @SubCategoryID INT,
    @ProductName VARCHAR(200),
    @Price DECIMAL(10,2)
AS
BEGIN
    INSERT INTO sales.Product
    (SellerID, SubCategoryID, ProductName, CurrentPrice)
    VALUES
    (@SellerID, @SubCategoryID, @ProductName, @Price);
END;
GO

CREATE OR ALTER PROCEDURE sales.usp_GetProductByID
    @ProductID INT
AS
BEGIN
    SELECT *
    FROM sales.Product
    WHERE ProductID = @ProductID;
END;
GO

CREATE OR ALTER PROCEDURE sales.usp_UpdateProductPrice
    @ProductID INT,
    @NewPrice DECIMAL(10,2)
AS
BEGIN
    UPDATE sales.Product
    SET CurrentPrice = @NewPrice
    WHERE ProductID = @ProductID;
END;
GO

CREATE OR ALTER PROCEDURE sales.usp_DeleteProduct
    @ProductID INT
AS
BEGIN
    DELETE FROM sales.Product
    WHERE ProductID = @ProductID;
END;
GO



CREATE OR ALTER PROCEDURE inventory.usp_CreateInventory
    @ProductID INT,
    @WarehouseID INT,
    @Quantity INT
AS
BEGIN
    INSERT INTO inventory.Inventory
    (ProductID, WarehouseID, QuantityAvailable)
    VALUES
    (@ProductID, @WarehouseID, @Quantity);
END;
GO

CREATE OR ALTER PROCEDURE inventory.usp_GetInventoryByProduct
    @ProductID INT
AS
BEGIN
    SELECT *
    FROM inventory.Inventory
    WHERE ProductID = @ProductID;
END;
GO

CREATE OR ALTER PROCEDURE inventory.usp_AddInventoryMovement
    @InventoryID INT,
    @QuantityChange INT,
    @MovementType VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (
            SELECT 1 FROM inventory.Inventory WHERE InventoryID = @InventoryID
        )
            THROW 50020, 'Inventory record not found.', 1;

        IF @MovementType NOT IN ('IN','OUT')
            THROW 50021, 'Invalid movement type.', 1;

        UPDATE inventory.Inventory
        SET QuantityAvailable =
            CASE
                WHEN @MovementType = 'OUT'
                    THEN QuantityAvailable - @QuantityChange
                ELSE QuantityAvailable + @QuantityChange
            END
        WHERE InventoryID = @InventoryID;

        INSERT INTO inventory.InventoryMovement
        (
            InventoryID,
            QuantityChange,
            MovementType,
            MovementDate
        )
        VALUES
        (
            @InventoryID,
            @QuantityChange,
            @MovementType,
            SYSDATETIME()
        );

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE inventory.usp_DeleteInventory
    @InventoryID INT
AS
BEGIN
    DELETE FROM inventory.Inventory
    WHERE InventoryID = @InventoryID;
END;
GO

CREATE OR ALTER PROCEDURE sales.usp_GetOrderByID
    @OrderID INT
AS
BEGIN
    SELECT *
    FROM sales.[Order]
    WHERE OrderID = @OrderID;
END;
GO

CREATE TYPE sales.OrderItemType AS TABLE
(
    ProductID  INT        NOT NULL,
    Quantity   INT        NOT NULL CHECK (Quantity > 0),
    UnitPrice  DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0)
);
GO

CREATE OR ALTER PROCEDURE sales.usp_CreateOrder_Full
(
    @CustomerID INT,
    @OrderItems sales.OrderItemType READONLY,
    @OrderID INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -----------------------------------
        -- 1️⃣ Validate Customer
        -----------------------------------
        IF NOT EXISTS (
            SELECT 1
            FROM core.Customer
            WHERE CustomerID = @CustomerID
        )
        BEGIN
            THROW 50001, 'Customer does not exist.', 1;
        END;

        -----------------------------------
        -- 2️⃣ Validate Inventory Availability
        -----------------------------------
        IF EXISTS (
            SELECT 1
            FROM @OrderItems oi
            JOIN inventory.Inventory i
                ON oi.ProductID = i.ProductID
            WHERE i.QuantityAvailable < oi.Quantity
        )
        BEGIN
            THROW 50002, 'Insufficient inventory for one or more products.', 1;
        END;

        -----------------------------------
        -- 3️⃣ Create Order
        -----------------------------------
        INSERT INTO sales.[Order]
        (
            CustomerID,
            OrderDate,
            TotalAmount
        )
        SELECT
            @CustomerID,
            SYSDATETIME(),
            SUM(oi.Quantity * oi.UnitPrice)
        FROM @OrderItems oi;

        SET @OrderID = SCOPE_IDENTITY();

        -----------------------------------
        -- 4️⃣ Insert Order Items
        -----------------------------------
        INSERT INTO sales.OrderItem
        (
            OrderID,
            ProductID,
            Quantity,
            UnitPrice
        )
        SELECT
            @OrderID,
            ProductID,
            Quantity,
            UnitPrice
        FROM @OrderItems;

        -----------------------------------
        -- 5️⃣ Update Inventory
        -----------------------------------
        UPDATE i
        SET i.QuantityAvailable = i.QuantityAvailable - oi.Quantity
        FROM inventory.Inventory i
        JOIN @OrderItems oi
            ON i.ProductID = oi.ProductID;

        -----------------------------------
        -- 6️⃣ Insert Initial Order Status
        -----------------------------------
        INSERT INTO sales.OrderStatusHistory
        (
            OrderID,
            Status,
            StatusDate
        )
        VALUES
        (
            @OrderID,
            'Created',
            SYSDATETIME()
        );

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();

        RAISERROR (@ErrorMessage, @ErrorSeverity, 1);
    END CATCH
END;
GO



CREATE OR ALTER PROCEDURE payment.usp_CreatePayment_Full
    @OrderID INT,
    @PaymentMethodID INT,
    @Amount DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM sales.[Order] WHERE OrderID = @OrderID)
            THROW 50030, 'Order not found.', 1;

        INSERT INTO payment.Payment
        (OrderID, PaymentMethodID, Amount, PaymentDate)
        VALUES
        (@OrderID, @PaymentMethodID, @Amount, SYSDATETIME());

        DECLARE @PaymentID INT = SCOPE_IDENTITY();

        INSERT INTO payment.PaymentStatusHistory
        (PaymentID, Status, StatusDate)
        VALUES
        (@PaymentID, 'Completed', SYSDATETIME());

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO



CREATE OR ALTER PROCEDURE logistics.usp_CreateShipment
    @OrderID INT,
    @ShipmentTypeID INT,
    @ShipmentDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM sales.[Order] WHERE OrderID = @OrderID)
            THROW 50040, 'Order not found.', 1;

        INSERT INTO logistics.Shipment
        (OrderID, ShipmentTypeID, ShipmentDate, Status, CustomerRating)
        VALUES
        (@OrderID, @ShipmentTypeID, @ShipmentDate, 'Pending', 3);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO



