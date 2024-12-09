from flask import Flask, request, jsonify, render_template
from datetime import datetime
import sqlite3
import os

app = Flask(__name__)

# Database initialization
def init_db():
    db_path = 'university.db'
    schema_path = 'schema.sql'
    
    try:
        if not os.path.exists(db_path):
            print(f"Creating database at {db_path}")
            conn = sqlite3.connect(db_path)
            print(f"Reading schema from {schema_path}")
            with open(schema_path, 'r') as f:
                conn.executescript(f.read())
            print("Database initialized successfully")
        else:
            print("Database already exists")
    except Exception as e:
        print(f"Error initializing database: {e}")

# Database connection helper
def get_db():
    conn = sqlite3.connect('university.db')
    conn.row_factory = sqlite3.Row
    return conn

print("Initializing database...")
init_db()
print("Starting Flask app...")


@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')

# API Routes (INSERT)
@app.route('/api/enroll_student', methods=['POST'])
def enroll_student():
    try:
        data = request.get_json()
        conn = get_db()
        cur = conn.cursor()
        
        # Insert into Students table
        cur.execute('''
            INSERT INTO Students (
                FirstName, LastName, DateOfBirth, Gender, 
                Address, PhoneNumber, Email, EnrollmentDate, ProgramID
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            data['first_name'], data['last_name'], data['dob'],
            data['gender'], data['address'], data['phone'],
            data['email'], datetime.now().strftime('%Y-%m-%d'),
            data['program_id']
        ))
        
        student_id = cur.lastrowid
        
        # Insert course enrollments
        for course_id in data['courses']:
            cur.execute('''
                INSERT INTO Enrollments (StudentID, CourseOfferingID, EnrollmentDate)
                VALUES (?, ?, ?)
            ''', (student_id, course_id, datetime.now().strftime('%Y-%m-%d')))
        
        conn.commit()
        return jsonify({'status': 'success', 'student_id': student_id})
    except Exception as e:
        conn.rollback()
        return jsonify({'status': 'error', 'message': str(e)}), 400
    finally:
        conn.close()

@app.route('/api/add_course', methods=['POST'])
def add_course():
    try:
        data = request.get_json()
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute('''
            INSERT INTO Courses (CourseCode, CourseName, Credits, DepartmentID)
            VALUES (?, ?, ?, ?)
        ''', (
            data['course_code'], data['course_name'],
            data['credits'], data['department_id']
        ))
        
        course_id = cur.lastrowid
        conn.commit()
        return jsonify({'status': 'success', 'course_id': course_id})
    except Exception as e:
        conn.rollback()
        return jsonify({'status': 'error', 'message': str(e)}), 400
    finally:
        conn.close()

@app.route('/api/add_professor', methods=['POST'])
def add_professor():
    try:
        data = request.get_json()
        conn = get_db()
        cur = conn.cursor()
        
        # First insert into Staff table
        cur.execute('''
            INSERT INTO Staff (FirstName, LastName, Title, Email, PhoneNumber, DepartmentID)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            data['first_name'], data['last_name'], data['title'],
            data['email'], data['phone'], data['department_id']
        ))
        
        staff_id = cur.lastrowid
        
        # Then insert into Professors table
        cur.execute('''
            INSERT INTO Professors (StaffID, Rank, OfficeLocation)
            VALUES (?, ?, ?)
        ''', (staff_id, data['rank'], data['office_location']))
        
        professor_id = cur.lastrowid
        conn.commit()
        return jsonify({'status': 'success', 'professor_id': professor_id})
    except Exception as e:
        conn.rollback()
        return jsonify({'status': 'error', 'message': str(e)}), 400
    finally:
        conn.close()

# API Routes (SELECT)
@app.route('/api/department_enrollment_report', methods=['GET'])
def department_enrollment_report():
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute('''
            SELECT 
                d.DepartmentName,
                COUNT(DISTINCT s.StudentID) as student_count,
                COUNT(DISTINCT c.CourseID) as course_count,
                COUNT(DISTINCT p.ProfessorID) as professor_count
            FROM Departments d
            LEFT JOIN Programs pr ON pr.DepartmentID = d.DepartmentID
            LEFT JOIN Students s ON s.ProgramID = pr.ProgramID
            LEFT JOIN Courses c ON c.DepartmentID = d.DepartmentID
            LEFT JOIN CourseOfferings co ON co.CourseID = c.CourseID
            LEFT JOIN Professors p ON co.InstructorID = p.ProfessorID
            GROUP BY d.DepartmentID, d.DepartmentName
            ORDER BY student_count DESC
        ''')
        
        results = [dict(row) for row in cur.fetchall()]
        return jsonify(results)
    finally:
        conn.close()

@app.route('/api/student_performance_report', methods=['GET'])
def student_performance_report():
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute('''
            SELECT 
                s.StudentID,
                s.FirstName || ' ' || s.LastName as student_name,
                p.ProgramName,
                COUNT(e.EnrollmentID) as courses_enrolled,
                AVG(CASE 
                    WHEN g.GradeValue = 'A' THEN 4.0
                    WHEN g.GradeValue = 'B' THEN 3.0
                    WHEN g.GradeValue = 'C' THEN 2.0
                    WHEN g.GradeValue = 'D' THEN 1.0
                    WHEN g.GradeValue = 'F' THEN 0.0
                    ELSE NULL
                END) as gpa
            FROM Students s
            JOIN Programs p ON p.ProgramID = s.ProgramID
            LEFT JOIN Enrollments e ON e.StudentID = s.StudentID
            LEFT JOIN Grades g ON g.GradeID = e.GradeID
            GROUP BY s.StudentID, s.FirstName, s.LastName, p.ProgramName
            ORDER BY gpa DESC NULLS LAST
        ''')
        
        results = [dict(row) for row in cur.fetchall()]
        return jsonify(results)
    finally:
        conn.close()

# Form and Report Pages with Dropdown Data
@app.route('/form/enroll_student', methods=['GET'])
def form_enroll_student():
    conn = get_db()
    cur = conn.cursor()
    
    # Fetch all Programs
    cur.execute("SELECT ProgramID, ProgramName FROM Programs ORDER BY ProgramName")
    programs = cur.fetchall()
    
    # Fetch all CourseOfferings
    cur.execute('''
        SELECT co.CourseOfferingID, c.CourseName, t.TermName
        FROM CourseOfferings co
        JOIN Courses c ON co.CourseID = c.CourseID
        JOIN Terms t ON co.TermID = t.TermID
        ORDER BY c.CourseName, t.TermName
    ''')
    offerings = cur.fetchall()
    
    conn.close()
    return render_template('enroll_student.html', programs=programs, offerings=offerings)

@app.route('/form/add_course', methods=['GET'])
def form_add_course():
    conn = get_db()
    cur = conn.cursor()
    
    # Fetch all Departments
    cur.execute("SELECT DepartmentID, DepartmentName FROM Departments ORDER BY DepartmentName")
    departments = cur.fetchall()
    
    conn.close()
    return render_template('add_course.html', departments=departments)

@app.route('/form/add_professor', methods=['GET'])
def form_add_professor():
    conn = get_db()
    cur = conn.cursor()
    
    # Fetch all Departments
    cur.execute("SELECT DepartmentID, DepartmentName FROM Departments ORDER BY DepartmentName")
    departments = cur.fetchall()
    
    conn.close()
    return render_template('add_professor.html', departments=departments)

@app.route('/report/department_enrollment', methods=['GET'])
def report_department_enrollment():
    return render_template('department_enrollment_report.html')

@app.route('/report/student_performance', methods=['GET'])
def report_student_performance():
    return render_template('student_performance_report.html')

@app.route('/navigation', methods=['GET'])
def navigation():
    return render_template('navigation.html')

if __name__ == '__main__':
    app.run(debug=True)
