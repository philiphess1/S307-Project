-- Table: Universities
CREATE TABLE Universities (
    UniversityID INT PRIMARY KEY,
    UniversityName VARCHAR2(100) NOT NULL,
    Address VARCHAR2(255),
    PhoneNumber VARCHAR2(15),
    Email VARCHAR2(100),
    Website VARCHAR2(100)
);


-- Table: Faculties
CREATE TABLE Faculties (
    FacultyID INT PRIMARY KEY,
    FacultyName VARCHAR2(100) NOT NULL,
    UniversityID INT NOT NULL,
    FOREIGN KEY (UniversityID) REFERENCES Universities(UniversityID)
);


-- Table: Departments
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR2(100) NOT NULL,
    FacultyID INT NOT NULL,
    FOREIGN KEY (FacultyID) REFERENCES Faculties(FacultyID)
);


-- Table: Staff
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    FirstName VARCHAR2(100) NOT NULL,
    LastName VARCHAR2(100) NOT NULL,
    Title VARCHAR2(50),
    Email VARCHAR2(100),
    PhoneNumber VARCHAR2(15),
    DepartmentID INT,
    UniversityID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    FOREIGN KEY (UniversityID) REFERENCES Universities(UniversityID)
);



-- Table: Professors
CREATE TABLE Professors (
    ProfessorID INT PRIMARY KEY,
    StaffID INT NOT NULL,
    Rank VARCHAR2(50) NOT NULL,
    OfficeLocation VARCHAR2(100),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);


-- Table: Programs
CREATE TABLE Programs (
    ProgramID INT PRIMARY KEY,
    ProgramName VARCHAR2(100) NOT NULL,
    DegreeType VARCHAR2(50) NOT NULL,
    DepartmentID INT NOT NULL,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);


-- Table: Courses
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseCode VARCHAR2(10) NOT NULL,
    CourseName VARCHAR2(100) NOT NULL,
    Credits INT NOT NULL,
    DepartmentID INT NOT NULL,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);


-- Table: Classrooms
CREATE TABLE Classrooms (
    ClassroomID INT PRIMARY KEY,
    Building VARCHAR2(100) NOT NULL,
    RoomNumber VARCHAR2(10) NOT NULL,
    Capacity INT NOT NULL
);


-- Table: Terms
CREATE TABLE Terms (
    TermID INT PRIMARY KEY,
    TermName VARCHAR2(50) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL
);

-- Table: CourseOfferings
CREATE TABLE CourseOfferings (
    CourseOfferingID INT PRIMARY KEY,
    CourseID INT NOT NULL,
    TermID INT NOT NULL,
    InstructorID INT NOT NULL,
    ClassroomID INT,
    Schedule VARCHAR2(50) NOT NULL,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    FOREIGN KEY (TermID) REFERENCES Terms(TermID),
    FOREIGN KEY (InstructorID) REFERENCES Professors(ProfessorID),
    FOREIGN KEY (ClassroomID) REFERENCES Classrooms(ClassroomID)
);

-- Table: Students
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR2(100) NOT NULL,
    LastName VARCHAR2(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR2(10),
    Address VARCHAR2(255),
    PhoneNumber VARCHAR2(15),
    Email VARCHAR2(100) NOT NULL,
    EnrollmentDate DATE NOT NULL,
    ProgramID INT,
    AdvisorID INT,
    FOREIGN KEY (ProgramID) REFERENCES Programs(ProgramID),
    FOREIGN KEY (AdvisorID) REFERENCES Professors(ProfessorID)
);


-- Table: Grades
CREATE TABLE Grades (
    GradeID INT PRIMARY KEY,
    GradeValue VARCHAR2(2) NOT NULL
);


-- Table: Enrollments
CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentID INT NOT NULL,
    CourseOfferingID INT NOT NULL,
    EnrollmentDate DATE NOT NULL,
    GradeID INT,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseOfferingID) REFERENCES CourseOfferings(CourseOfferingID),
    FOREIGN KEY (GradeID) REFERENCES Grades(GradeID)
);


-- Table: Clubs
CREATE TABLE Clubs (
    ClubID INT PRIMARY KEY,
    ClubName VARCHAR2(100) NOT NULL,
    Description VARCHAR2(255),
    AdvisorID INT,
    FOREIGN KEY (AdvisorID) REFERENCES Staff(StaffID)
);


-- Table: StudentClubs
CREATE TABLE StudentClubs (
    StudentID INT NOT NULL,
    ClubID INT NOT NULL,
    JoinDate DATE NOT NULL,
    Role VARCHAR2(50),
    PRIMARY KEY (StudentID, ClubID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (ClubID) REFERENCES Clubs(ClubID)
);


-- Table: Libraries
CREATE TABLE Libraries (
    LibraryID INT PRIMARY KEY,
    LibraryName VARCHAR2(100) NOT NULL,
    Location VARCHAR2(255),
    OpenHours VARCHAR2(50),
    UniversityID INT NOT NULL,
    FOREIGN KEY (UniversityID) REFERENCES Universities(UniversityID)
);


-- Table: Books
CREATE TABLE Books (
    BookID INT PRIMARY KEY,
    ISBN VARCHAR2(13) NOT NULL,
    Title VARCHAR2(255) NOT NULL,
    Author VARCHAR2(100),
    Publisher VARCHAR2(100),
    YearPublished INT,
    LibraryID INT NOT NULL,
    FOREIGN KEY (LibraryID) REFERENCES Libraries(LibraryID)
);

-- Table: BookLoans
CREATE TABLE BookLoans (
    LoanID INT PRIMARY KEY,
    StudentID INT NOT NULL,
    BookID INT NOT NULL,
    LoanDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);


-- Table: Scholarships
CREATE TABLE Scholarships (
    ScholarshipID INT PRIMARY KEY,
    ScholarshipName VARCHAR2(100) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    Criteria VARCHAR2(255)
);


-- Table: StudentScholarships
CREATE TABLE StudentScholarships (
    StudentID INT NOT NULL,
    ScholarshipID INT NOT NULL,
    AwardDate DATE NOT NULL,
    PRIMARY KEY (StudentID, ScholarshipID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (ScholarshipID) REFERENCES Scholarships(ScholarshipID)
);

--------
-- Indexes
--------


CREATE INDEX idx_Enrollments_StudentID
ON Enrollments (StudentID);


--


CREATE INDEX idx_CourseOfferings_CourseID
ON CourseOfferings (CourseID);