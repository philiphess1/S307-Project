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
