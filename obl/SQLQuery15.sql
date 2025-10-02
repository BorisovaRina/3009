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
(N'�����������',3,N'������� �.�.'),
(N'�������',2,N'������ �.�.');

INSERT INTO Wards (WardNumber,DepartmentID,Beds) VALUES
(101,1,4),(102,1,3),(201,2,6);

INSERT INTO Patients (FullName,Diagnosis,AdmissionDate) VALUES
(N'������ �.�.',N'�����������',CAST(GETDATE() AS DATE)),
(N'������ �.�.',N'�������','2025-09-01'),
(N'�������� �.�.',N'����','2025-09-15');

INSERT INTO Staff (FullName,Position,DepartmentID) VALUES
(N'�������� �.�.',N'����',1),
(N'�������� �.�.',N'���������',1),
(N'������ �.�.',N'����',2);

-- SELECT
-- �) ������ �� ����������
SELECT d.Name, w.WardNumber, w.Beds
FROM Wards w JOIN Departments d ON d.DepartmentID = w.DepartmentID;

-- �) �������� �� ����������
SELECT d.Name, s.FullName, s.Position
FROM Staff s JOIN Departments d ON d.DepartmentID = s.DepartmentID;

-- �) ���������� ���� � ���������
SELECT d.Name, SUM(w.Beds) AS TotalBeds
FROM Departments d LEFT JOIN Wards w ON w.DepartmentID = d.DepartmentID
GROUP BY d.Name;
