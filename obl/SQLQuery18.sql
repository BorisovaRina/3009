IF DB_ID(N'FitnessDB') IS NOT NULL DROP DATABASE FitnessDB;
GO
CREATE DATABASE FitnessDB;
GO
USE FitnessDB;
GO

CREATE TABLE Clients (
    ClientID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Phone NVARCHAR(30),
    RegDate DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE))
);

CREATE TABLE Trainers (
    TrainerID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Speciality NVARCHAR(100),
    RatePerHour DECIMAL(10,2) NOT NULL CHECK (RatePerHour > 0)
);

CREATE TABLE Memberships (
    MembershipID INT IDENTITY PRIMARY KEY,
    Type NVARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    ValidDays INT NOT NULL CHECK (ValidDays BETWEEN 7 AND 365)
);

CREATE TABLE ClientMemberships (
    ClientMembershipID INT IDENTITY PRIMARY KEY,
    ClientID INT NOT NULL,
    MembershipID INT NOT NULL,
    StartDate DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
    EndDate AS DATEADD(DAY, (SELECT ValidDays FROM Memberships m WHERE m.MembershipID = ClientMemberships.MembershipID), StartDate) PERSISTED,
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (MembershipID) REFERENCES Memberships(MembershipID)
);

CREATE TABLE Classes (
    ClassID INT IDENTITY PRIMARY KEY,
    ClassDate DATE NOT NULL,
    ClassTime TIME NOT NULL,
    TrainerID INT NOT NULL,
    Type NVARCHAR(50) NOT NULL,
    Capacity INT NOT NULL CHECK (Capacity BETWEEN 1 AND 20),
    FOREIGN KEY (TrainerID) REFERENCES Trainers(TrainerID)
);

CREATE TABLE ClassEnrollments (
    ClassID INT NOT NULL,
    ClientID INT NOT NULL,
    PRIMARY KEY (ClassID, ClientID),
    FOREIGN KEY (ClassID) REFERENCES Classes(ClassID),
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID)
);

-- Данные
INSERT INTO Clients (FullName,Phone) VALUES
(N'Ильин Д.',N'+7-999-1'),
(N'Романова К.',N'+7-999-2'),
(N'Пак А.',N'+7-999-3'),
(N'Чжан Л.',N'+7-999-4');

INSERT INTO Trainers (FullName,Speciality,RatePerHour) VALUES
(N'Степанов И.',N'Йога',1200),
(N'Морозова А.',N'Функционал',1500);

INSERT INTO Memberships (Type,Price,ValidDays) VALUES
(N'Month',3000,30),
(N'Quarter',8000,90);

INSERT INTO ClientMemberships (ClientID,MembershipID,StartDate) VALUES
(1,1,CAST(GETDATE() AS DATE)),
(2,2,CAST(GETDATE() AS DATE)),
(3,1,DATEADD(DAY,-10,CAST(GETDATE() AS DATE))),
(4,1,DATEADD(DAY,-40,CAST(GETDATE() AS DATE))); -- для проверки просрочки

INSERT INTO Classes (ClassDate,ClassTime,TrainerID,Type,Capacity) VALUES
(DATEADD(DAY,1,CAST(GETDATE() AS DATE)),'10:00',1,N'Йога',10),
(DATEADD(DAY,1,CAST(GETDATE() AS DATE)),'12:00',2,N'HIIT',8);

INSERT INTO ClassEnrollments (ClassID,ClientID) VALUES
(1,1),(1,2),(2,2),(2,3);

-- SELECT
-- а) Проверка срока действия абонемента
SELECT c.FullName, cm.StartDate, cm.EndDate,
       CASE WHEN CAST(GETDATE() AS DATE) <= cm.EndDate THEN N'Active' ELSE N'Expired' END AS Status
FROM ClientMemberships cm JOIN Clients c ON c.ClientID=cm.ClientID;

-- б) Записи на занятия с тренерами
SELECT cl.ClassDate, cl.ClassTime, cl.Type, t.FullName AS Trainer, COUNT(e.ClientID) AS Enrolled
FROM Classes cl
JOIN Trainers t ON t.TrainerID=cl.TrainerID
LEFT JOIN ClassEnrollments e ON e.ClassID=cl.ClassID
GROUP BY cl.ClassDate, cl.ClassTime, cl.Type, t.FullName;

-- в) Клиенты без активного абонемента
WITH lastm AS (
  SELECT ClientID, MAX(EndDate) AS MaxEnd FROM ClientMemberships GROUP BY ClientID
)
SELECT c.FullName
FROM Clients c
LEFT JOIN lastm l ON l.ClientID=c.ClientID
WHERE l.MaxEnd IS NULL OR l.MaxEnd < CAST(GETDATE() AS DATE);
