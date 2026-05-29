CREATE DATABASE StudentManagement;

USE StudentManagement;

CREATE TABLE Students(
	StudentId INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(50),
    Gender VARCHAR(1),
    Age INT,
    Grade VARCHAR(10),
    MathScore INT,
    ScienceScore INT,
    EnglishScore INT
);

INSERT INTO Students(Name,Gender,Age,Grade,MathScore,ScienceScore,EnglishScore)
VALUES
('Rahul Sharma', 'M', 20, 'A', 90, 85, 88),
('Priya Singh', 'F', 19, 'B', 78, 82, 80),
('Amit Verma', 'M', 21, 'A', 95, 92, 91),
('Sneha Patel', 'F', 20, 'C', 65, 70, 68),
('Rohan Das', 'M', 22, 'B', 81, 79, 84),
('Anjali Mehta', 'F', 19, 'A', 88, 90, 87),
('Vikas Roy', 'M', 21, 'C', 60, 58, 62),
('Neha Kapoor', 'F', 20, 'B', 76, 74, 79),
('Arjun Nair', 'M', 23, 'A', 92, 89, 94),
('Kavya Iyer', 'F', 22, 'B', 84, 86, 83);

SELECT * FROM Students;

SELECT 
    AVG(MathScore) AS AverageMath,
    AVG(ScienceScore) AS AverageScience,
    AVG(EnglishScore) AS AverageEnglish
FROM Students;

SELECT 
    StudentID,
    Name,
    (MathScore + ScienceScore + EnglishScore) AS TotalScore
FROM Students
ORDER BY TotalScore DESC
LIMIT 1;

SELECT 
    Grade,
    COUNT(*) AS TotalStudents
FROM Students
GROUP BY Grade;

SELECT 
    Gender,
    AVG((MathScore + ScienceScore + EnglishScore)/3) AS AverageScore
FROM Students
GROUP BY Gender;

SELECT 
    StudentID,
    Name,
    MathScore
FROM Students
WHERE MathScore > 80;

UPDATE Students
SET Grade = 'A'
WHERE StudentID = 2;

SELECT * FROM Students;
