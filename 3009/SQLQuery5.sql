DROP TABLE OrderDetails
DROP TABLE Products

CREATE TABLE Products
(
	ProductID char(5) NOT NULL PRIMARY KEY,
	[Description] varchar(15),
	UnitPrice smallmoney NOT NULL,
	[Weight] numeric(18, 0) NULL
)


CREATE TABLE OrderDetails
(
	OrderID int NOT NULL,
	LineItem int NOT NULL,
	ProductID char(5) NOT NULL,
	Qty int NOT NULL,

    FOREIGN KEY(OrderID) REFERENCES Orders(OrderID),
	FOREIGN KEY(ProductID) REFERENCES Products(ProductID),
	PRIMARY KEY (OrderId, LineItem)
)

INSERT Products
VALUES
( 'LV231', 'Джинсы', 45, 2),
( 'DG30', 'Ремень', 30,  1),
( 'GC111', 'Футболка', 20,  2),
( 'LV12', 'Обувь', 26,  2),
( 'GC11', 'Шапка', 32,  1)


INSERT OrderDetails
VALUES
( 1, 1, 'LV231', 5 ),
( 1, 2, 'DG30', 5 ),
( 1, 3, 'LV12', 5 ),
( 2, 1, 'GC11', 10 ),
( 2, 2, 'GC111', 15 ),
( 3, 1, 'LV12', 20 ),
( 3, 2, 'GC11', 18 )


SELECT * FROM Customers
SELECT * FROM Employees
SELECT * FROM Orders
SELECT * FROM OrderDetails
SELECT * FROM Products