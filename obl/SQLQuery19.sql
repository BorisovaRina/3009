IF DB_ID(N'UniversityDB') IS NOT NULL DROP DATABASE UniversityDB;
GO
CREATE DATABASE UniversityDB;
GO
USE UniversityDB;
GO

CREATE TABLE Students (
    StudentID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    GroupCode NVARCHAR(20) NOT NULL,
    EntryYear INT NOT NULL CHECK (EntryYear BETWEEN 2000 AND YEAR(GETDATE()))
);

CREATE TABLE Teachers (
    TeacherID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Position NVARCHAR(100) NOT NULL,
    Department NVARCHAR(100) NOT NULL
);

CREATE TABLE Courses (
    CourseID INT IDENTITY PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Semester INT NOT NULL CHECK (Semester BETWEEN 1 AND 8),
    Credits INT NOT NULL CHECK (Credits BETWEEN 1 AND 10)
);

CREATE TABLE StudentCourses (
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    UNIQUE (StudentID, CourseID),
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

CREATE TABLE Grades (
    GradeID INT IDENTITY PRIMARY KEY,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    GradeDate DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
    GradeValue INT NOT NULL CHECK (GradeValue BETWEEN 2 AND 5),
    CONSTRAINT UQ_OneGrade UNIQUE (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

-- Данные
INSERT INTO Students (FullName,GroupCode,EntryYear) VALUES
(N'Иванов И.',N'CS-101',2023),
(N'Павлова А.',N'CS-101',2024),
(N'Ким П.',N'DB-201',2022);

INSERT INTO Teachers (FullName,Position,Department) VALUES
(N'Сергеев Н.',N'Профессор',N'Кибернетика'),
(N'Орлова Т.',N'Доцент',N'ИС');

INSERT INTO Courses (Title,Semester,Credits) VALUES
(N'Базы данных',3,5),
(N'Алгоритмы',2,5),
(N'Операционные системы',4,4);

INSERT INTO StudentCourses (StudentID,CourseID) VALUES
(1,1),(1,2),(2,1),(3,1),(3,3);

INSERT INTO Grades (StudentID,CourseID,GradeValue) VALUES
(1,1,5),(1,2,4),(2,1,5),(3,3,3);

-- SELECT
-- а) Успеваемость по курсам
SELECT s.FullName, c.Title, g.GradeValue
FROM Grades g
JOIN Students s ON s.StudentID=g.StudentID
JOIN Courses c ON c.CourseID=g.CourseID;

-- б) Студенты на курсе "Базы данных"
SELECT s.FullName
FROM StudentCourses sc
JOIN Students s ON s.StudentID=sc.StudentID
JOIN Courses c ON c.CourseID=sc.CourseID
WHERE c.Title=N'Базы данных';

-- в) Средний балл по студентам
SELECT s.FullName, AVG(CAST(g.GradeValue AS DECIMAL(4,2))) AS AvgGrade
FROM Students s
LEFT JOIN Grades g ON g.StudentID=s.StudentID
GROUP BY s.FullName;
