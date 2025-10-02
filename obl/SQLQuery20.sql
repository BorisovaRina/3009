IF DB_ID(N'LibraryDB') IS NOT NULL DROP DATABASE LibraryDB;
GO
CREATE DATABASE LibraryDB;
GO
USE LibraryDB;
GO

CREATE TABLE Authors (
    AuthorID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Country NVARCHAR(100),
    LifeYears NVARCHAR(50)
);

CREATE TABLE Books (
    BookID INT IDENTITY PRIMARY KEY,
    Title NVARCHAR(300) NOT NULL,
    PublishYear INT NOT NULL CHECK (PublishYear BETWEEN 1500 AND YEAR(GETDATE())),
    ISBN NVARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE BookAuthors (
    BookID INT NOT NULL,
    AuthorID INT NOT NULL,
    PRIMARY KEY (BookID, AuthorID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

CREATE TABLE Readers (
    ReaderID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Phone NVARCHAR(30),
    RegDate DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE))
);

CREATE TABLE Issues (
    IssueID INT IDENTITY PRIMARY KEY,
    ReaderID INT NOT NULL,
    BookID INT NOT NULL,
    IssueDate DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
    DueDate DATE NOT NULL,
    ReturnDate DATE NULL,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    CONSTRAINT CK_Due CHECK (DueDate > IssueDate)
);

-- Ограничение: максимум 3 невозвращённые книги на читателя (через фильтруемую уникальность не решить, используем CHECK с функцией – для простоты оставим контролем через запросы)
-- Данные
INSERT INTO Authors (FullName,Country,LifeYears) VALUES
(N'А.С. Пушкин',N'Россия',N'1799–1837'),
(N'Л.Н. Толстой',N'Россия',N'1828–1910');

INSERT INTO Books (Title,PublishYear,ISBN) VALUES
(N'Евгений Онегин',1833,N'ISBN-0001'),
(N'Война и мир',1869,N'ISBN-0002');

INSERT INTO BookAuthors (BookID,AuthorID) VALUES
(1,1),(2,2);

INSERT INTO Readers (FullName,Phone) VALUES
(N'Иванов И.',N'+7-999-1'),
(N'Смирнова А.',N'+7-999-2');

INSERT INTO Issues (ReaderID,BookID,IssueDate,DueDate,ReturnDate) VALUES
(1,1,CAST(GETDATE() AS DATE),DATEADD(DAY,14,CAST(GETDATE() AS DATE)),NULL),
(1,2,DATEADD(DAY,-10,CAST(GETDATE() AS DATE)),DATEADD(DAY,4,CAST(GETDATE() AS DATE)),NULL),
(2,2,CAST(GETDATE() AS DATE),DATEADD(DAY,10,CAST(GETDATE() AS DATE)),DATEADD(DAY,5,CAST(GETDATE() AS DATE)));

-- SELECT
-- а) Невозвращённые книги
SELECT r.FullName, b.Title, i.IssueDate, i.DueDate
FROM Issues i
JOIN Readers r ON r.ReaderID=i.ReaderID
JOIN Books b ON b.BookID=i.BookID
WHERE i.ReturnDate IS NULL;

-- б) Книги и авторы
SELECT b.Title, STRING_AGG(a.FullName, N', ') AS Authors
FROM Books b
JOIN BookAuthors ba ON ba.BookID=b.BookID
JOIN Authors a ON a.AuthorID=ba.AuthorID
GROUP BY b.Title;

-- в) Число книг на читателя
SELECT r.FullName, COUNT(*) AS TotalIssues
FROM Issues i JOIN Readers r ON r.ReaderID=i.ReaderID
GROUP BY r.FullName;
