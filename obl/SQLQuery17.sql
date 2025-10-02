IF DB_ID(N'StomDB') IS NOT NULL DROP DATABASE StomDB;
GO
CREATE DATABASE StomDB;
GO
USE StomDB;
GO

CREATE TABLE Patients (
    PatientID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Phone NVARCHAR(30),
    FirstVisit DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE))
);

CREATE TABLE Dentists (
    DentistID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Speciality NVARCHAR(100) NOT NULL,
    WorkSchedule NVARCHAR(200) NULL
);

CREATE TABLE Services (
    ServiceID INT IDENTITY PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    DurationMin INT NOT NULL CHECK (DurationMin BETWEEN 15 AND 180),
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0)
);

CREATE TABLE DentistServices (
    DentistID INT NOT NULL,
    ServiceID INT NOT NULL,
    PRIMARY KEY (DentistID, ServiceID),
    FOREIGN KEY (DentistID) REFERENCES Dentists(DentistID),
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID)
);

CREATE TABLE Bookings (
    BookingID INT IDENTITY PRIMARY KEY,
    VisitDate DATE NOT NULL CHECK (VisitDate >= CAST(GETDATE() AS DATE)),
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    PatientID INT NOT NULL,
    DentistID INT NOT NULL,
    ServiceID INT NOT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DentistID) REFERENCES Dentists(DentistID),
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID),
    CONSTRAINT CK_TimeOrder CHECK (EndTime > StartTime)
);

-- Индекс для проверки пересечений (простая защита уникальности слота)
CREATE UNIQUE INDEX UX_Dentist_Slot ON Bookings(DentistID, VisitDate, StartTime);

-- Данные
INSERT INTO Patients (FullName,Phone) VALUES
(N'Иванов И.',N'+7999-111'),
(N'Смирнова А.',N'+7999-222'),
(N'Ким П.',N'+7999-333');

INSERT INTO Dentists (FullName,Speciality,WorkSchedule) VALUES
(N'Поляков С.',N'Терапевт',N'Пн-Пт'),
(N'Белова Н.',N'Ортодонт',N'Пн-Ср-Пт');

INSERT INTO Services (Title,DurationMin,Price) VALUES
(N'Чистка',40,2000),
(N'Пломбирование',60,3500),
(N'Консультация',30,1000);

INSERT INTO DentistServices (DentistID,ServiceID) VALUES
(1,1),(1,2),(2,3);

INSERT INTO Bookings (VisitDate,StartTime,EndTime,PatientID,DentistID,ServiceID) VALUES
(DATEADD(DAY,1,CAST(GETDATE() AS DATE)),'09:00','10:00',1,1,1),
(DATEADD(DAY,1,CAST(GETDATE() AS DATE)),'10:00','11:00',2,1,2),
(DATEADD(DAY,2,CAST(GETDATE() AS DATE)),'12:00','12:30',3,2,3);

-- SELECT
-- а) Расписание с пациентами и услугами
SELECT b.BookingID,b.VisitDate,b.StartTime,p.FullName AS Patient,d.FullName AS Dentist,s.Title
FROM Bookings b
JOIN Patients p ON p.PatientID=b.PatientID
JOIN Dentists d ON d.DentistID=b.DentistID
JOIN Services s ON s.ServiceID=b.ServiceID;

-- б) Проверка соответствия инструмента/услуги врачу (через доступные услуги)
SELECT b.BookingID,
       CASE WHEN ds.ServiceID IS NOT NULL THEN N'OK' ELSE N'Not allowed' END AS Allowed
FROM Bookings b
LEFT JOIN DentistServices ds ON ds.DentistID=b.DentistID AND ds.ServiceID=b.ServiceID;

-- в) Занятость врача по дням
SELECT d.FullName, b.VisitDate, COUNT(*) AS Slots
FROM Bookings b JOIN Dentists d ON d.DentistID=b.DentistID
GROUP BY d.FullName, b.VisitDate;
