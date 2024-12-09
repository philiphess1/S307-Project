from flask import Flask, request, jsonify
from datetime import datetime
import sqlite3
import os

app = Flask(__name__)

# Database initialization
def init_db():
    if not os.path.exists('university.db'):
        conn = sqlite3.connect('university.db')
        with open('schema.sql', 'r') as f:
            conn.executescript(f.read())
        conn.close()

# Database connection helper
def get_db():
    conn = sqlite3.connect('university.db')
    conn.row_factory = sqlite3.Row
    return conn

# Form Routes (INSERT)

@app.route('/', methods=['GET'])
def index():
    return 'Welcome to the University API'

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

# Report Routes (SELECT)

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

if __name__ == '__main__':
    init_db()
    app.run(debug=True)