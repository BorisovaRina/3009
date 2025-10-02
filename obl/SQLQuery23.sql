IF DB_ID(N'HotelDB') IS NOT NULL DROP DATABASE HotelDB;
GO
CREATE DATABASE HotelDB;
GO
USE HotelDB;
GO

CREATE TABLE Rooms (
    RoomID INT IDENTITY PRIMARY KEY,
    RoomNo INT NOT NULL UNIQUE,
    Type NVARCHAR(50) NOT NULL,
    Floor INT NOT NULL CHECK (Floor BETWEEN 1 AND 25),
    PricePerNight DECIMAL(10,2) NOT NULL CHECK (PricePerNight > 0)
);

CREATE TABLE Guests (
    GuestID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Passport NVARCHAR(50) NOT NULL UNIQUE,
    Phone NVARCHAR(30),
    Country NVARCHAR(100)
);

CREATE TABLE Bookings (
    BookingID INT IDENTITY PRIMARY KEY,
    RoomID INT NOT NULL,
    GuestID INT NOT NULL,
    CheckIn DATE NOT NULL,
    CheckOut DATE NOT NULL,
    Total AS (DATEDIFF(DAY, CheckIn, CheckOut) * (SELECT PricePerNight FROM Rooms r WHERE r.RoomID = Bookings.RoomID)) PERSISTED,
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID),
    FOREIGN KEY (GuestID) REFERENCES Guests(GuestID),
    CONSTRAINT CK_Dates CHECK (CheckOut > CheckIn)
);

-- Индекс на проверку пересечения дат (упрощённый, исключает дубль идентичных интервалов)
CREATE UNIQUE INDEX UX_Room_Period ON Bookings(RoomID, CheckIn, CheckOut);

-- Данные
INSERT INTO Rooms (RoomNo,Type,Floor,PricePerNight) VALUES
(101,N'Standard',1,3000),
(202,N'Deluxe',2,5000),
(1501,N'Suite',15,12000);

INSERT INTO Guests (FullName,Passport,Phone,Country) VALUES
(N'Иванов И.',N'PA12345',N'+7-999-1',N'RU'),
(N'Smith J.',N'US99887',N'+1-111',N'US');

INSERT INTO Bookings (RoomID,GuestID,CheckIn,CheckOut) VALUES
(1,1,DATEADD(DAY,1,CAST(GETDATE() AS DATE)),DATEADD(DAY,4,CAST(GETDATE() AS DATE))),
(2,2,DATEADD(DAY,2,CAST(GETDATE() AS DATE)),DATEADD(DAY,5,CAST(GETDATE() AS DATE)));

-- SELECT
-- а) Бронирования с итоговой стоимостью
SELECT b.BookingID, r.RoomNo, g.FullName, b.CheckIn, b.CheckOut, b.Total
FROM Bookings b
JOIN Rooms r ON r.RoomID=b.RoomID
JOIN Guests g ON g.GuestID=b.GuestID;

-- б) Доступность номеров на дату (пример на завтра)
DECLARE @d DATE = DATEADD(DAY,1,CAST(GETDATE() AS DATE));
SELECT r.RoomNo
FROM Rooms r
WHERE NOT EXISTS (
  SELECT 1 FROM Bookings b
  WHERE b.RoomID=r.RoomID AND @d >= b.CheckIn AND @d < b.CheckOut
);

-- в) Доход по типам
SELECT r.Type, SUM(b.Total) AS Revenue
FROM Bookings b JOIN Rooms r ON r.RoomID=b.RoomID
GROUP BY r.Type;
