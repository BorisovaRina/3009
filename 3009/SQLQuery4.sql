DROP TABLE Orders
DROP TABLE Employees
DROP TABLE Customers
DROP TABLE OrderDetails

CREATE TABLE Employees
	(
		EmployeeID int NOT NULL IDENTITY 
			PRIMARY KEY,
		FName nvarchar(15) NOT NULL,
		LName nvarchar(15) NOT NULL,
		MName nvarchar(15) NOT NULL,
		Salary money NOT NULL,
		PriorSalary money NOT NULL,
		HireDate date NOT NULL,
		TerminationDate date NULL,
		ManagerEmpID int NULL
	)  
GO

CREATE TABLE Customers
	(
	CustomerNo int NOT NULL IDENTITY
		PRIMARY KEY,
	FName nvarchar(15) NOT NULL,
	LName nvarchar(15) NOT NULL,
	MName nvarchar(15) NULL,
	Address1 nvarchar(50) NOT NULL,
	Address2 nvarchar(50) NULL,
	City nchar(10) NOT NULL,
	Phone char(12) NOT NULL UNIQUE,
	DateInSystem date NULL,

	CHECK (Phone LIKE '([0-9][0-9][0-9])[0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
	)  
GO

CREATE TABLE Orders
(
	OrderID int NOT NULL IDENTITY PRIMARY KEY,
	OrderDate date NOT NULL,
	CustomerNo int,
	EmployeeID int,

	FOREIGN KEY(CustomerNo) REFERENCES Customers(CustomerNo),
	FOREIGN KEY(EmployeeID) REFERENCES Employees(EmployeeID),
)

CREATE TABLE OrderDetails
(
	OrderID int NOT NULL,
	LineItem int NOT NULL,
	ProductID char(5) NOT NULL,
	ProductDescription varchar(15),
	UnitPrice smallmoney NOT NULL,
	Qty int NOT NULL,
	TotalPrice as Qty * UnitPrice,

    FOREIGN KEY(OrderID) REFERENCES Orders(OrderID),
	PRIMARY KEY (OrderId, LineItem)
)

INSERT Employees
(FName, MName, LName, Salary, PriorSalary, HireDate, TerminationDate, ManagerEmpID)
VALUES
('Василий', 'Петрович', 'Лященко', 5000, 800, '11/20/2009', NULL, NULL),
('Иван', 'Иванович', 'Белецкий', 2000, 0, '11/20/2009', NULL, 1),
('Петр', 'Григорьевич', 'Дяченко', 1000, 0, '11/20/2009', NULL, 2),
('Светлана', 'Олеговна', 'Лялечкина', 800, 0, '11/20/2009', NULL, 2);
GO

INSERT Customers 
(LName, FName, MName, Address1, Address2, City, Phone,DateInSystem)
VALUES
('Круковский','Анатолий','Петрович','Лужная 15',NULL,'Харьков','(092)3212211','11/20/2009'),
('Дурнев','Виктор','Викторович','Зелинская 10',NULL,'Киев','(067)4242132','08/03/2010'),
('Унакий','Зигмунд','федорович','Дихтяревская 5',NULL,'Киев','(092)7612343','08/17/2010'),
('Левченко','Виталий','Викторович','Глущенка 5','Драйзера 12','Киев','(053)3456788','08/20/2010'),
('Выжлецов','Олег','Евстафьевич','Киевская 3','Одесская 8','Чернигов','(044)2134212','09/18/2010');
GO

INSERT Orders
VALUES
( '2009-12-28', 1, 2),
( '2010-09-01', 3, 4),
( '2010-09-18', 5, 4)

INSERT OrderDetails
VALUES
( 1, 1, 'LV231', 'Джинсы', 45, 5 ),
( 1, 2, 'DG30', 'Ремень', 30, 5 ),
( 1, 3, 'LV12', 'Обувь', 26, 5 ),
( 2, 1, 'GC11', 'Шапка', 32, 10 ),
( 2, 2, 'GC111', 'Футболка', 20, 15 ),
( 3, 1, 'LV12', 'Обувь', 26, 20 ),
( 3, 2, 'GC11', 'Шапка', 32, 18 )


SELECT * FROM Customers
SELECT * FROM Employees
SELECT * FROM Orders
SELECT * FROM OrderDetails