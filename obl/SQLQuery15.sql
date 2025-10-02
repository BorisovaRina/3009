IF DB_ID(N'BolnicaDB') IS NOT NULL DROP DATABASE BolnicaDB;
GO
CREATE DATABASE BolnicaDB;
GO
USE BolnicaDB;
GO

CREATE TABLE Departments (
    DepartmentID INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Floor INT NOT NULL CHECK (Floor BETWEEN 1 AND 25),
    Head NVARCHAR(200) NOT NULL
);

CREATE TABLE Wards (
    WardID INT IDENTITY PRIMARY KEY,
    WardNumber INT NOT NULL,
    DepartmentID INT NOT NULL,
    Beds INT NOT NULL CHECK (Beds BETWEEN 1 AND 6),
    CONSTRAINT FK_Ward_Dept FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    CONSTRAINT UQ_Ward_Department UNIQUE(DepartmentID, WardNumber)
);

CREATE TABLE Patients (
    PatientID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Diagnosis NVARCHAR(200) NOT NULL,
    AdmissionDate DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE))
);

CREATE TABLE Staff (
    StaffID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Position NVARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    CONSTRAINT FK_Staff_Dept FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

INSERT INTO Departments (Name, Floor, Head) VALUES
(N'Кардиология',3,N'Сорокин В.В.'),
(N'Терапия',2,N'Белова И.И.');

INSERT INTO Wards (WardNumber,DepartmentID,Beds) VALUES
(101,1,4),(102,1,3),(201,2,6);

INSERT INTO Patients (FullName,Diagnosis,AdmissionDate) VALUES
(N'Иванов И.И.',N'Гипертензия',CAST(GETDATE() AS DATE)),
(N'Петров П.П.',N'Инфаркт','2025-09-01'),
(N'Сидорова А.А.',N'ОРВИ','2025-09-15');

INSERT INTO Staff (FullName,Position,DepartmentID) VALUES
(N'Кузнецов А.А.',N'Врач',1),
(N'Новикова О.О.',N'Медсестра',1),
(N'Громов Д.Д.',N'Врач',2);

-- SELECT
-- а) Палаты по отделениям
SELECT d.Name, w.WardNumber, w.Beds
FROM Wards w JOIN Departments d ON d.DepartmentID = w.DepartmentID;

-- б) Персонал по отделениям
SELECT d.Name, s.FullName, s.Position
FROM Staff s JOIN Departments d ON d.DepartmentID = s.DepartmentID;

-- в) Количество коек в отделении
SELECT d.Name, SUM(w.Beds) AS TotalBeds
FROM Departments d LEFT JOIN Wards w ON w.DepartmentID = d.DepartmentID
GROUP BY d.Name;
