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

-- ������
INSERT INTO Students (FullName,GroupCode,EntryYear) VALUES
(N'������ �.',N'CS-101',2023),
(N'������� �.',N'CS-101',2024),
(N'��� �.',N'DB-201',2022);

INSERT INTO Teachers (FullName,Position,Department) VALUES
(N'������� �.',N'���������',N'�����������'),
(N'������ �.',N'������',N'��');

INSERT INTO Courses (Title,Semester,Credits) VALUES
(N'���� ������',3,5),
(N'���������',2,5),
(N'������������ �������',4,4);

INSERT INTO StudentCourses (StudentID,CourseID) VALUES
(1,1),(1,2),(2,1),(3,1),(3,3);

INSERT INTO Grades (StudentID,CourseID,GradeValue) VALUES
(1,1,5),(1,2,4),(2,1,5),(3,3,3);

-- SELECT
-- �) ������������ �� ������
SELECT s.FullName, c.Title, g.GradeValue
FROM Grades g
JOIN Students s ON s.StudentID=g.StudentID
JOIN Courses c ON c.CourseID=g.CourseID;

-- �) �������� �� ����� "���� ������"
SELECT s.FullName
FROM StudentCourses sc
JOIN Students s ON s.StudentID=sc.StudentID
JOIN Courses c ON c.CourseID=sc.CourseID
WHERE c.Title=N'���� ������';

-- �) ������� ���� �� ���������
SELECT s.FullName, AVG(CAST(g.GradeValue AS DECIMAL(4,2))) AS AvgGrade
FROM Students s
LEFT JOIN Grades g ON g.StudentID=s.StudentID
GROUP BY s.FullName;
