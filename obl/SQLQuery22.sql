IF DB_ID(N'RestaurantDB') IS NOT NULL DROP DATABASE RestaurantDB;
GO
CREATE DATABASE RestaurantDB;
GO
USE RestaurantDB;
GO

CREATE TABLE Dishes (
    DishID INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL UNIQUE,
    Category NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    PortionWeight INT NOT NULL CHECK (PortionWeight BETWEEN 100 AND 1000),
    Available BIT NOT NULL DEFAULT 1
);

CREATE TABLE Chefs (
    ChefID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Speciality NVARCHAR(100) NOT NULL,
    Shift NVARCHAR(50) NOT NULL
);

CREATE TABLE Orders (
    OrderID INT IDENTITY PRIMARY KEY,
    TableNo INT NOT NULL CHECK (TableNo BETWEEN 1 AND 50),
    Waiter NVARCHAR(100) NOT NULL,
    OrderSum AS (
        (SELECT SUM(oi.Qty * d.Price)
         FROM OrderItems oi JOIN Dishes d ON d.DishID = oi.DishID
         WHERE oi.OrderID = Orders.OrderID)
    ) PERSISTED
);

CREATE TABLE OrderItems (
    OrderID INT NOT NULL,
    DishID INT NOT NULL,
    Qty INT NOT NULL CHECK (Qty > 0),
    PRIMARY KEY (OrderID, DishID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (DishID) REFERENCES Dishes(DishID)
);

-- ������
INSERT INTO Dishes (Name,Category,Price,PortionWeight,Available) VALUES
(N'����',N'���',250,350,1),
(N'�����',N'�������',1200,300,1),
(N'����� ������',N'�����',450,250,0);

INSERT INTO Chefs (FullName,Speciality,Shift) VALUES
(N'������� �.',N'�����',N'����'),
(N'�������� �.',N'������',N'�����');

INSERT INTO Orders (TableNo,Waiter) VALUES (5,N'����'),(7,N'������');

INSERT INTO OrderItems (OrderID,DishID,Qty) VALUES
(1,1,2),(1,2,1),(2,1,1);

-- SELECT
-- �) ������ ������� � �����
SELECT o.OrderID, o.TableNo, o.Waiter, o.OrderSum
FROM Orders o;

-- �) ��������� �����
SELECT Name, Category, Price FROM Dishes WHERE Available = 1;

-- �) ������������ ����
SELECT d.Name, SUM(oi.Qty) AS Ordered
FROM OrderItems oi JOIN Dishes d ON d.DishID=oi.DishID
GROUP BY d.Name
ORDER BY Ordered DESC;
