USE master
DROP DATABASE newDB;

CREATE DATABASE newDB;

USE newDB

CREATE TABLE Customers (
    CustomerNo INT PRIMARY KEY,
    FName NVARCHAR(50),
    LName NVARCHAR(50),
    MName NVARCHAR(50),
    Address1 NVARCHAR(100),
    Address2 NVARCHAR(100),
    City NVARCHAR(50),
    Phone NVARCHAR(20),
    DateInSystem DATE
);


CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FName NVARCHAR(50),
    LName NVARCHAR(50),
    MName NVARCHAR(50),
    Salary MONEY,
    PriorSalary MONEY,
    HireDate DATE,
    TerminationDate DATE,
    ManagerEmpID INT NULL
);

CREATE TABLE Products (
    ProdID INT PRIMARY KEY,
    Description NVARCHAR(50),
    UnitPrice MONEY,
    Weight NUMERIC(18, 0)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerNo INT FOREIGN KEY REFERENCES Customers(CustomerNo),
    OrderDate DATE,
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID)
);

CREATE TABLE OrderDetails (
    OrderID INT,
    LineItem INT,
    ProdID INT,
    Qty INT,
    UnitPrice MONEY,
    PRIMARY KEY (OrderID, LineItem),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProdID) REFERENCES Products(ProdID)
);
