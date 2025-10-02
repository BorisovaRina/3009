
-- 1) Создание БД
IF DB_ID(N'PoliklinikaDB') IS NOT NULL DROP DATABASE PoliklinikaDB;
GO
CREATE DATABASE PoliklinikaDB;
GO
USE PoliklinikaDB;
GO

-- 2) Таблицы
CREATE TABLE Patients (
    PatientID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    BirthDate DATE NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M','F')),
    Phone NVARCHAR(20) NULL
);

CREATE TABLE Doctors (
    DoctorID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Speciality NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    ExperienceYears INT NOT NULL CHECK (ExperienceYears >= 0)
);

CREATE TABLE Diagnoses (
    DiagnosisCode NVARCHAR(20) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL UNIQUE,
    Description NVARCHAR(500) NULL
);

CREATE TABLE Appointments (
    AppointmentID INT IDENTITY PRIMARY KEY,
    VisitDate DATE NOT NULL CHECK (VisitDate <= CAST(GETDATE() AS DATE)),
    VisitTime TIME NOT NULL,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    DiagnosisCode NVARCHAR(20) NULL,
    CONSTRAINT FK_App_Patient FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    CONSTRAINT FK_App_Doctor FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    CONSTRAINT FK_App_Diag FOREIGN KEY (DiagnosisCode) REFERENCES Diagnoses(DiagnosisCode)
);

-- 3) Данные
INSERT INTO Patients (FullName,BirthDate,Gender,Phone) VALUES
(N'Иванов Иван', '1990-01-10','M',N'+79990000001'),
(N'Петров Пётр','1985-05-20','M',N'+79990000002'),
(N'Сидорова Анна','1992-03-15','F',N'+79990000003'),
(N'Кузнецова Ольга','2000-12-01','F',N'+79990000004'),
(N'Смирнов Алексей','1978-07-07','M',N'+79990000005');

INSERT INTO Doctors (FullName,Speciality,Category,ExperienceYears) VALUES
(N'Доктор Хаус',N'Терапевт',N'Высшая',15),
(N'Стрельцов С.',N'Кардиолог',N'Первая',10),
(N'Беляева Н.',N'ЛОР',N'Вторая',5);

INSERT INTO Diagnoses (DiagnosisCode,Title,Description) VALUES
(N'J00',N'Острый насморк',N'Ринит'),
(N'I10',N'Гипертензия',N'Повышенное давление'),
(N'K29',N'Гастрит',N'Воспаление желудка');

INSERT INTO Appointments (VisitDate,VisitTime,PatientID,DoctorID,DiagnosisCode) VALUES
(CAST(GETDATE() AS DATE),'09:00',1,1,N'J00'),
(CAST(GETDATE() AS DATE),'10:00',2,2,N'I10'),
(CAST(GETDATE() AS DATE),'11:30',3,1,N'K29'),
(CAST(GETDATE() AS DATE),'12:00',4,3,N'J00'),
(CAST(GETDATE() AS DATE),'13:00',5,2,N'I10');

-- 4) SELECT с JOIN
-- а) Приёмы с пациентами и врачами
SELECT a.AppointmentID, a.VisitDate, a.VisitTime, p.FullName AS Patient, d.FullName AS Doctor, diag.Title
FROM Appointments a
JOIN Patients p ON p.PatientID = a.PatientID
JOIN Doctors d ON d.DoctorID = a.DoctorID
LEFT JOIN Diagnoses diag ON diag.DiagnosisCode = a.DiagnosisCode;

-- б) Кол-во приёмов по врачам
SELECT d.FullName, COUNT(*) AS AppCount
FROM Appointments a
JOIN Doctors d ON d.DoctorID = a.DoctorID
GROUP BY d.FullName;

-- в) Пациенты и их последние диагнозы
SELECT p.FullName, MAX(a.VisitDate) AS LastVisit, MAX(diag.Title) WITHIN GROUP (ORDER BY a.VisitDate)
FROM Patients p
LEFT JOIN Appointments a ON a.PatientID = p.PatientID
LEFT JOIN Diagnoses diag ON diag.DiagnosisCode = a.DiagnosisCode
GROUP BY p.FullName;
