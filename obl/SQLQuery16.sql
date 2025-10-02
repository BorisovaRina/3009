IF DB_ID(N'AptekaDB') IS NOT NULL DROP DATABASE AptekaDB;
GO
CREATE DATABASE AptekaDB;
GO
USE AptekaDB;
GO

CREATE TABLE Drugs (
    DrugID INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    Manufacturer NVARCHAR(200) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    ExpiryDate DATE NOT NULL CHECK (ExpiryDate > CAST(GETDATE() AS DATE))
);

CREATE TABLE Suppliers (
    SupplierID INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL UNIQUE,
    Phone NVARCHAR(30) NULL,
    Address NVARCHAR(300) NULL
);

CREATE TABLE DrugSuppliers (
    DrugID INT NOT NULL,
    SupplierID INT NOT NULL,
    PRIMARY KEY(DrugID, SupplierID),
    FOREIGN KEY (DrugID) REFERENCES Drugs(DrugID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

CREATE TABLE Sales (
    SaleID INT IDENTITY PRIMARY KEY,
    SaleDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    DrugID INT NOT NULL,
    Qty INT NOT NULL CHECK (Qty > 0),
    Amount AS (CAST(Qty AS DECIMAL(10,2)) * PriceAtSale) PERSISTED,
    PriceAtSale DECIMAL(10,2) NOT NULL CHECK (PriceAtSale > 0),
    FOREIGN KEY (DrugID) REFERENCES Drugs(DrugID)
);

-- Данные
INSERT INTO Drugs (Name,Manufacturer,Price,ExpiryDate) VALUES
(N'Парацетамол',N'ФармРус',50,'2026-01-01'),
(N'Ибупрофен',N'Гедеон Рихтер',120,'2026-06-01'),
(N'АкваМарис',N'Ядран',300,'2027-01-01');

INSERT INTO Suppliers (Name,Phone,Address) VALUES
(N'МедСнаб',N'+7-999-000-11-22',N'Москва'),
(N'ФармЛогистик',N'+7-999-000-33-44',N'СПб');

INSERT INTO DrugSuppliers (DrugID,SupplierID) VALUES
(1,1),(1,2),(2,1),(3,2);

INSERT INTO Sales (DrugID,Qty,PriceAtSale) VALUES
(1,2,55),(2,1,125),(3,3,310);

-- SELECT
-- а) Продажи с суммами
SELECT s.SaleID, s.SaleDate, d.Name, s.Qty, s.Amount
FROM Sales s JOIN Drugs d ON d.DrugID = s.DrugID;

-- б) Поставщики по препаратам
SELECT d.Name AS Drug, STRING_AGG(sup.Name, N', ') AS Suppliers
FROM Drugs d
JOIN DrugSuppliers ds ON ds.DrugID = d.DrugID
JOIN Suppliers sup ON sup.SupplierID = ds.SupplierID
GROUP BY d.Name;

-- в) Товары с истекающим сроком (пример фильтра)
SELECT Name, ExpiryDate FROM Drugs
WHERE ExpiryDate <= DATEADD(MONTH, 6, CAST(GETDATE() AS DATE));
