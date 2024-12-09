-- Table: Universities
CREATE TABLE Universities (
    UniversityID INTEGER PRIMARY KEY,
    UniversityName TEXT NOT NULL,
    Address TEXT,
    PhoneNumber TEXT,
    Email TEXT,
    Website TEXT
);

-- Table: Faculties
CREATE TABLE Faculties (
    FacultyID INTEGER PRIMARY KEY,
    FacultyName TEXT NOT NULL,
    UniversityID INTEGER NOT NULL,
    FOREIGN KEY (UniversityID) REFERENCES Universities(UniversityID)
);

-- Table: Departments
CREATE TABLE Departments (
    DepartmentID INTEGER PRIMARY KEY,
    DepartmentName TEXT NOT NULL,
    FacultyID INTEGER NOT NULL,
    FOREIGN KEY (FacultyID) REFERENCES Faculties(FacultyID)
);

-- Table: Staff
CREATE TABLE Staff (
    StaffID INTEGER PRIMARY KEY,
    FirstName TEXT NOT NULL,
    LastName TEXT NOT NULL,
    Title TEXT,
    Email TEXT,
    PhoneNumber TEXT,
    DepartmentID INTEGER,
    UniversityID INTEGER,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    FOREIGN KEY (UniversityID) REFERENCES Universities(UniversityID)
);

-- Table: Professors
CREATE TABLE Professors (
    ProfessorID INTEGER PRIMARY KEY,
    StaffID INTEGER NOT NULL,
    Rank TEXT NOT NULL,
    OfficeLocation TEXT,
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

-- Table: Programs
CREATE TABLE Programs (
    ProgramID INTEGER PRIMARY KEY,
    ProgramName TEXT NOT NULL,
    DegreeType TEXT NOT NULL,
    DepartmentID INTEGER NOT NULL,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- Table: Courses
CREATE TABLE Courses (
    CourseID INTEGER PRIMARY KEY,
    CourseCode TEXT NOT NULL,
    CourseName TEXT NOT NULL,
    Credits INTEGER NOT NULL,
    DepartmentID INTEGER NOT NULL,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- Table: Classrooms
CREATE TABLE Classrooms (
    ClassroomID INTEGER PRIMARY KEY,
    Building TEXT NOT NULL,
    RoomNumber TEXT NOT NULL,
    Capacity INTEGER NOT NULL
);

-- Table: Terms
CREATE TABLE Terms (
    TermID INTEGER PRIMARY KEY,
    TermName TEXT NOT NULL,
    StartDate TEXT NOT NULL,
    EndDate TEXT NOT NULL
);

-- Table: CourseOfferings
CREATE TABLE CourseOfferings (
    CourseOfferingID INTEGER PRIMARY KEY,
    CourseID INTEGER NOT NULL,
    TermID INTEGER NOT NULL,
    InstructorID INTEGER NOT NULL,
    ClassroomID INTEGER,
    Schedule TEXT NOT NULL,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    FOREIGN KEY (TermID) REFERENCES Terms(TermID),
    FOREIGN KEY (InstructorID) REFERENCES Professors(ProfessorID),
    FOREIGN KEY (ClassroomID) REFERENCES Classrooms(ClassroomID)
);

-- Table: Students
CREATE TABLE Students (
    StudentID INTEGER PRIMARY KEY,
    FirstName TEXT NOT NULL,
    LastName TEXT NOT NULL,
    DateOfBirth TEXT NOT NULL,
    Gender TEXT,
    Address TEXT,
    PhoneNumber TEXT,
    Email TEXT NOT NULL,
    EnrollmentDate TEXT NOT NULL,
    ProgramID INTEGER,
    AdvisorID INTEGER,
    FOREIGN KEY (ProgramID) REFERENCES Programs(ProgramID),
    FOREIGN KEY (AdvisorID) REFERENCES Professors(ProfessorID)
);

-- Table: Grades
CREATE TABLE Grades (
    GradeID INTEGER PRIMARY KEY,
    GradeValue TEXT NOT NULL
);

-- Table: Enrollments
CREATE TABLE Enrollments (
    EnrollmentID INTEGER PRIMARY KEY,
    StudentID INTEGER NOT NULL,
    CourseOfferingID INTEGER NOT NULL,
    EnrollmentDate TEXT NOT NULL,
    GradeID INTEGER,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseOfferingID) REFERENCES CourseOfferings(CourseOfferingID),
    FOREIGN KEY (GradeID) REFERENCES Grades(GradeID)
);

-- Table: Clubs
CREATE TABLE Clubs (
    ClubID INTEGER PRIMARY KEY,
    ClubName TEXT NOT NULL,
    Description TEXT,
    AdvisorID INTEGER,
    FOREIGN KEY (AdvisorID) REFERENCES Staff(StaffID)
);

-- Table: StudentClubs
CREATE TABLE StudentClubs (
    StudentID INTEGER NOT NULL,
    ClubID INTEGER NOT NULL,
    JoinDate TEXT NOT NULL,
    Role TEXT,
    PRIMARY KEY (StudentID, ClubID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (ClubID) REFERENCES Clubs(ClubID)
);

-- Table: Libraries
CREATE TABLE Libraries (
    LibraryID INTEGER PRIMARY KEY,
    LibraryName TEXT NOT NULL,
    Location TEXT,
    OpenHours TEXT,
    UniversityID INTEGER NOT NULL,
    FOREIGN KEY (UniversityID) REFERENCES Universities(UniversityID)
);

-- Table: Books
CREATE TABLE Books (
    BookID INTEGER PRIMARY KEY,
    ISBN TEXT NOT NULL,
    Title TEXT NOT NULL,
    Author TEXT,
    Publisher TEXT,
    YearPublished INTEGER,
    LibraryID INTEGER NOT NULL,
    FOREIGN KEY (LibraryID) REFERENCES Libraries(LibraryID)
);

-- Table: BookLoans
CREATE TABLE BookLoans (
    LoanID INTEGER PRIMARY KEY,
    StudentID INTEGER NOT NULL,
    BookID INTEGER NOT NULL,
    LoanDate TEXT NOT NULL,
    DueDate TEXT NOT NULL,
    ReturnDate TEXT,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- Table: Scholarships
CREATE TABLE Scholarships (
    ScholarshipID INTEGER PRIMARY KEY,
    ScholarshipName TEXT NOT NULL,
    Amount REAL NOT NULL,
    Criteria TEXT
);

-- Table: StudentScholarships
CREATE TABLE StudentScholarships (
    StudentID INTEGER NOT NULL,
    ScholarshipID INTEGER NOT NULL,
    AwardDate TEXT NOT NULL,
    PRIMARY KEY (StudentID, ScholarshipID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (ScholarshipID) REFERENCES Scholarships(ScholarshipID)
);

-- Indexes
CREATE INDEX idx_Enrollments_StudentID ON Enrollments (StudentID);
CREATE INDEX idx_CourseOfferings_CourseID ON CourseOfferings (CourseID);

-- Insert into Universities
INSERT INTO Universities (UniversityName, Address, PhoneNumber, Email, Website)
VALUES ('Sunshine State University', '123 College Ave', '555-1234', 'info@ssu.edu', 'http://www.ssu.edu'),
       ('Crescent Valley Institute', '456 University Rd', '555-5678', 'contact@cvi.edu', 'http://www.cvi.edu');

-- Insert into Faculties (assuming UniversityID=1 for these faculties)
INSERT INTO Faculties (FacultyName, UniversityID)
VALUES ('Faculty of Arts and Sciences', 1),
       ('Faculty of Engineering', 1),
       ('Faculty of Business', 1);

-- Insert into Departments
-- Faculties inserted above: 1=Arts & Sci, 2=Engineering, 3=Business
INSERT INTO Departments (DepartmentName, FacultyID)
VALUES ('Computer Science', 2),
       ('Mechanical Engineering', 2),
       ('Mathematics', 1),
       ('English', 1),
       ('Finance', 3),
       ('Marketing', 3);

-- Insert into Staff (linking to Departments and University=1)
-- Departments: 1=CS, 2=ME, 3=Math, 4=English, 5=Finance, 6=Marketing
INSERT INTO Staff (FirstName, LastName, Title, Email, PhoneNumber, DepartmentID, UniversityID)
VALUES ('Alice', 'Johnson', 'Ms.', 'alice.johnson@ssu.edu', '555-1111', 1, 1),
       ('Bob', 'Carter', 'Mr.', 'bob.carter@ssu.edu', '555-2222', 2, 1),
       ('Cathy', 'Wong', 'Dr.', 'cathy.wong@ssu.edu', '555-3333', 3, 1),
       ('David', 'Lee', 'Dr.', 'david.lee@ssu.edu', '555-4444', 1, 1);

-- Insert into Professors (StaffID must exist)
-- Let's make Cathy (StaffID=3) and David (StaffID=4) professors
INSERT INTO Professors (StaffID, Rank, OfficeLocation)
VALUES (3, 'Associate Professor', 'Room 210'),
       (4, 'Professor', 'Room 305');

-- Insert into Programs (link Departments)
-- DepartmentID=1(CS),2(ME),3(Math),5(Finance),6(Marketing)
INSERT INTO Programs (ProgramName, DegreeType, DepartmentID)
VALUES ('BSc in Computer Science', 'BSc', 1),
       ('BSc in Mechanical Engineering', 'BSc', 2),
       ('BA in Mathematics', 'BA', 3),
       ('BBA in Finance', 'BBA', 5),
       ('BBA in Marketing', 'BBA', 6);

-- Insert into Courses
-- CS: DeptID=1, ME: DeptID=2, Math:3, Finance:5
INSERT INTO Courses (CourseCode, CourseName, Credits, DepartmentID)
VALUES ('CS101', 'Intro to Programming', 3, 1),
       ('CS201', 'Data Structures', 3, 1),
       ('ME101', 'Intro to Mechanics', 3, 2),
       ('MATH101', 'Calculus I', 4, 3),
       ('FIN201', 'Corporate Finance', 3, 5);

-- Insert into Classrooms
INSERT INTO Classrooms (Building, RoomNumber, Capacity)
VALUES ('Engineering Hall', 'E101', 100),
       ('Science Building', 'S202', 50),
       ('Business Building', 'B303', 60);

-- Insert into Terms
INSERT INTO Terms (TermName, StartDate, EndDate)
VALUES ('Fall 2024', '2024-09-01', '2024-12-15'),
       ('Spring 2025', '2025-01-10', '2025-05-01');

-- Insert into CourseOfferings
-- Professors: #1=Cathy (ProfID=1), #2=David (ProfID=2)
-- Courses: CS101=1, CS201=2, ME101=3, MATH101=4, FIN201=5
-- Terms: Fall2024=1, Spring2025=2
-- Classrooms: E101=1, S202=2, B303=3
INSERT INTO CourseOfferings (CourseID, TermID, InstructorID, ClassroomID, Schedule)
VALUES (1, 1, 1, 1, 'MWF 9:00-9:50'),
       (2, 1, 1, 1, 'TTh 10:00-11:15'),
       (3, 1, 2, 2, 'MWF 10:00-10:50'),
       (4, 1, 2, 2, 'TTh 8:00-9:15'),
       (5, 2, 2, 3, 'MWF 1:00-1:50');

-- Insert into Students
-- AdvisorID = ProfessorID=1 or 2
-- Programs: CS=1, ME=2, Math=3, Finance=5, Marketing=6
INSERT INTO Students (FirstName, LastName, DateOfBirth, Gender, Address, PhoneNumber, Email, EnrollmentDate, ProgramID, AdvisorID)
VALUES ('Emily', 'Smith', '2001-05-20', 'F', '789 Maple St', '555-5555', 'emily.smith@ssu.edu', '2024-09-01', 1, 1),
       ('John', 'Doe', '2000-11-10', 'M', '111 Oak Ave', '555-6666', 'john.doe@ssu.edu', '2024-09-01', 2, 2),
       ('Maria', 'Gonzalez', '2002-02-15', 'F', '222 Pine Rd', '555-7777', 'maria.g@ssu.edu', '2024-09-01', 3, 1),
       ('Alex', 'Brown', '2001-07-30', 'M', '333 Elm St', '555-8888', 'alex.brown@ssu.edu', '2024-09-01', 5, 2),
       ('Sophia', 'Lee', '2001-09-25', 'F', '444 Birch Ln', '555-9999', 'sophia.lee@ssu.edu', '2024-09-01', 6, 1);

-- Insert into Grades
INSERT INTO Grades (GradeValue)
VALUES ('A'), ('B'), ('C'), ('D'), ('F');

-- Insert into Enrollments
-- CourseOfferings: 
--   1=CS101(Fall),2=CS201(Fall),3=ME101(Fall),4=Math101(Fall),5=Fin201(Spring)
-- Students: 1=Emily,2=John,3=Maria,4=Alex,5=Sophia
INSERT INTO Enrollments (StudentID, CourseOfferingID, EnrollmentDate)
VALUES (1, 1, '2024-09-02'),
       (1, 2, '2024-09-02'),
       (2, 3, '2024-09-02'),
       (3, 4, '2024-09-02'),
       (4, 1, '2024-09-02'),
       (4, 5, '2025-01-11'),
       (5, 2, '2024-09-02');

-- Assign some grades to these enrollments
UPDATE Enrollments SET GradeID = 1 WHERE StudentID=1 AND CourseOfferingID=1; -- Emily: A in CS101
UPDATE Enrollments SET GradeID = 2 WHERE StudentID=1 AND CourseOfferingID=2; -- Emily: B in CS201
UPDATE Enrollments SET GradeID = 3 WHERE StudentID=2; -- John: C in ME101
UPDATE Enrollments SET GradeID = 1 WHERE StudentID=3; -- Maria: A in Math101
UPDATE Enrollments SET GradeID = 2 WHERE StudentID=4 AND CourseOfferingID=1; -- Alex: B in CS101
UPDATE Enrollments SET GradeID = 1 WHERE StudentID=4 AND CourseOfferingID=5; -- Alex: A in FIN201
UPDATE Enrollments SET GradeID = 4 WHERE StudentID=5; -- Sophia: D in CS201

-- Insert into Clubs (AdvisorID references StaffID)
-- Staff: 1=Alice,2=Bob,3=Cathy,4=David
INSERT INTO Clubs (ClubName, Description, AdvisorID)
VALUES ('Robotics Club', 'Building and programming robots', 3),
       ('Literary Society', 'Discussing literature and writing', 4);

-- Insert into StudentClubs
-- Clubs: 1=Robotics, 2=Literary
-- Students: 1=Emily, 2=John, 3=Maria, 5=Sophia
INSERT INTO StudentClubs (StudentID, ClubID, JoinDate, Role)
VALUES (1, 1, '2024-09-10', 'Member'),
       (2, 1, '2024-09-10', 'Treasurer'),
       (3, 2, '2024-09-11', 'Member'),
       (5, 2, '2024-09-11', 'President');

-- Insert into Libraries (UniversityID=1)
INSERT INTO Libraries (LibraryName, Location, OpenHours, UniversityID)
VALUES ('Main Library', 'Central Campus', '08:00-22:00', 1),
       ('Engineering Library', 'Engineering Wing', '09:00-20:00', 1);

-- Insert into Books (LibraryID=1=Main, 2=Engineering)
INSERT INTO Books (ISBN, Title, Author, Publisher, YearPublished, LibraryID)
VALUES ('9780131103627', 'The C Programming Language', 'Kernighan and Ritchie', 'Prentice Hall', 1988, 1),
       ('9780134093413', 'Clean Code', 'Robert C. Martin', 'Prentice Hall', 2008, 1),
       ('9780262033848', 'Introduction to Algorithms', 'Cormen, Leiserson, Rivest, Stein', 'MIT Press', 2009, 2);

-- Insert into BookLoans (Students: 1=Emily,2=John,3=Maria; Books:1=The C Prog Lang,2=Clean Code,3=Intro to Algos)
INSERT INTO BookLoans (StudentID, BookID, LoanDate, DueDate)
VALUES (1, 1, '2024-09-15', '2024-09-30'),
       (2, 2, '2024-09-16', '2024-10-01'),
       (3, 3, '2024-09-17', '2024-10-05');

-- Insert into Scholarships
INSERT INTO Scholarships (ScholarshipName, Amount, Criteria)
VALUES ('Academic Excellence', 2000.00, 'GPA > 3.5'),
       ('Need-Based Aid', 1500.00, 'Proven Financial Need');

-- Insert into StudentScholarships
-- Students: 1=Emily,3=Maria,4=Alex
-- Scholarships: 1=Academic Excellence, 2=Need-Based Aid
INSERT INTO StudentScholarships (StudentID, ScholarshipID, AwardDate)
VALUES (1, 1, '2024-09-01'),
       (3, 2, '2024-09-05'),
       (4, 1, '2024-09-10');

