New-AzureRmSqlDatabase  -ResourceGroupName cuculandcloud-rg `
    -ServerName cuculandcloud-sqlsvr `
    -DatabaseName cuculandcloud-sqldb03 `
    -RequestedServiceObjectiveName "S3"


-- Create Person table

CREATE TABLE Person
(
PersonId   INT IDENTITY PRIMARY KEY,
FirstName   NVARCHAR(128) NOT NULL,
MiddelInitial NVARCHAR(10),
LastName   NVARCHAR(128) NOT NULL,
DateOfBirth   DATE NOT NULL
)

-- Create Student table

CREATE TABLE Student
(
StudentId INT IDENTITY PRIMARY KEY,
PersonId  INT REFERENCES Person (PersonId),
Email   NVARCHAR(256)
)

-- Create Course table

CREATE TABLE Course
(
CourseId  INT IDENTITY PRIMARY KEY,
Name   NVARCHAR(50) NOT NULL,
Teacher   NVARCHAR(256) NOT NULL
) 

-- Create Credit table

CREATE TABLE Credit
(
StudentId   INT REFERENCES Student (StudentId),
CourseId   INT REFERENCES Course (CourseId),
Grade   DECIMAL(5,2) CHECK (Grade <= 100.00),
Attempt   TINYINT,
CONSTRAINT  [UQ_studentgrades] UNIQUE CLUSTERED
(
StudentId, CourseId, Grade, Attempt
)
)


bcp Course in SampleCourseData -S cuculandcloud-sqlsvr.database.windows.net -d cuculandcloud-sqldb01 -U dbadmin -P Pa55w.rd -q -c -t ","
bcp Person in SamplePersonData -S cuculandcloud-sqlsvr.database.windows.net -d cuculandcloud-sqldb01 -U dbadmin -P Pa55w.rd -q -c -t ","
bcp Student in SampleStudentData -S cuculandcloud-sqlsvr.database.windows.net -d cuculandcloud-sqldb01 -U dbadmin -P Pa55w.rd -q -c -t ","
bcp Credit in SampleCreditData -S cuculandcloud-sqlsvr.database.windows.net -d cuculandcloud-sqldb01 -U dbadmin -P Pa55w.rd -q -c -t ","


