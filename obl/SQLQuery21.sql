IF DB_ID(N'EShopDB') IS NOT NULL DROP DATABASE EShopDB;
GO
CREATE DATABASE EShopDB;
GO
USE EShopDB;
GO

CREATE TABLE Categories (
    CategoryID INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(300)
);

CREATE TABLE Customers (
    CustomerID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Email NVARCHAR(200) NOT NULL UNIQUE,
    Phone NVARCHAR(30),
    Address NVARCHAR(300)
);

CREATE TABLE Products (
    ProductID INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    CategoryID INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    Stock INT NOT NULL DEFAULT 0 CHECK (Stock >= 0),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE Orders (
    OrderID INT IDENTITY PRIMARY KEY,
    OrderDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CustomerID INT NOT NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT N'Новый',
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderItems (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Qty INT NOT NULL CHECK (Qty > 0),
    PriceAtOrder DECIMAL(10,2) NOT NULL CHECK (PriceAtOrder > 0),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Данные
INSERT INTO Categories (Name,Description) VALUES
(N'Электроника',N'Гаджеты'),
(N'Книги',N'Печатная продукция');

INSERT INTO Customers (FullName,Email,Phone,Address) VALUES
(N'Иванов И.',N'ivanov@example.com',N'+7-999-1',N'Москва'),
(N'Петров П.',N'petrov@example.com',N'+7-999-2',N'СПб');

INSERT INTO Products (Name,CategoryID,Price,Stock) VALUES
(N'Смартфон',1,30000,10),
(N'Ноутбук',1,80000,5),
(N'Роман',2,700,50);

INSERT INTO Orders (CustomerID) VALUES (1),(2);

INSERT INTO OrderItems (OrderID,ProductID,Qty,PriceAtOrder) VALUES
(1,1,1,30000),
(1,3,2,700),
(2,2,1,80000);

-- SELECT
-- а) Заказ с деталями
SELECT o.OrderID, o.OrderDate, c.FullName, SUM(oi.Qty*oi.PriceAtOrder) AS Total
FROM Orders o
JOIN Customers c ON c.CustomerID=o.CustomerID
JOIN OrderItems oi ON oi.OrderID=o.OrderID
GROUP BY o.OrderID,o.OrderDate,c.FullName;

-- б) Остатки по категориям
SELECT cat.Name, SUM(p.Stock) AS TotalStock
FROM Products p JOIN Categories cat ON cat.CategoryID=p.CategoryID
GROUP BY cat.Name;

-- в) Популярные товары
SELECT p.Name, SUM(oi.Qty) AS Sold
FROM OrderItems oi JOIN Products p ON p.ProductID=oi.ProductID
GROUP BY p.Name
ORDER BY Sold DESC;
