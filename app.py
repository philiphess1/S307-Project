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
            conn.close()
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

# ----------------------------
# API ROUTES - CREATE
# ----------------------------
@app.route('/api/enroll_student', methods=['POST'])
def enroll_student():
    try:
        data = request.get_json()
        conn = get_db()
        cur = conn.cursor()
        
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
        
        for course_id in data.get('courses', []):
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
        
        # Insert into Staff
        cur.execute('''
            INSERT INTO Staff (FirstName, LastName, Title, Email, PhoneNumber, DepartmentID)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            data['first_name'], data['last_name'], data['title'],
            data['email'], data['phone'], data['department_id']
        ))
        
        staff_id = cur.lastrowid
        
        # Insert into Professors
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

@app.route('/api/department_enrollment_report', methods=['GET'])
def department_enrollment_report():
    try:
        conn = get_db()
        cur = conn.cursor()

        cur.execute('''
            SELECT 
                c.CourseName,
                c.CourseCode,
                d.DepartmentName,
                s_prof.FirstName || ' ' || s_prof.LastName as ProfessorName,
                s.StudentID,
                s.FirstName || ' ' || s.LastName as StudentName
            FROM Courses c
            JOIN Departments d ON c.DepartmentID = d.DepartmentID
            JOIN CourseOfferings co ON co.CourseID = c.CourseID
            JOIN Professors p ON co.InstructorID = p.ProfessorID
            JOIN Staff s_prof ON p.StaffID = s_prof.StaffID
            JOIN Enrollments e ON e.CourseOfferingID = co.CourseOfferingID
            JOIN Students s ON e.StudentID = s.StudentID
            ORDER BY c.CourseName, s.LastName;
        ''')

        results = {}
        for row in cur.fetchall():
            course = f"{row['CourseCode']} - {row['CourseName']}"
            if course not in results:
                results[course] = {
                    "Department": row["DepartmentName"],
                    "Professor": row["ProfessorName"],
                    "Students": []
                }
            results[course]["Students"].append(row["StudentName"])
        
        return jsonify(results)
    finally:
        conn.close()

@app.route('/api/student_performance_report', methods=['GET'])
def student_performance_report():
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
    conn.close()
    return jsonify(results)

# ----------------------------
# API ROUTES - READ/UPDATE/DELETE STUDENTS
# ----------------------------
@app.route('/api/students', methods=['GET'])
def get_students():
    conn = get_db()
    cur = conn.cursor()
    cur.execute('''
        SELECT StudentID, FirstName, LastName
        FROM Students
        ORDER BY LastName, FirstName
    ''')
    students = [dict(row) for row in cur.fetchall()]
    conn.close()
    return jsonify(students)

@app.route('/api/students/<int:student_id>', methods=['GET'])
def get_student(student_id):
    conn = get_db()
    cur = conn.cursor()
    cur.execute('''
        SELECT StudentID, FirstName, LastName, DateOfBirth, Gender, Address, PhoneNumber, Email, ProgramID
        FROM Students
        WHERE StudentID = ?
    ''', (student_id,))
    row = cur.fetchone()
    conn.close()
    if row:
        return jsonify(dict(row))
    else:
        return jsonify({'status': 'error', 'message': 'Student not found'}), 404

@app.route('/api/update_student/<int:student_id>', methods=['PUT'])
def update_student(student_id):
    try:
        data = request.get_json()
        conn = get_db()
        cur = conn.cursor()

        # Check if student exists
        cur.execute('SELECT StudentID FROM Students WHERE StudentID = ?', (student_id,))
        existing = cur.fetchone()
        if not existing:
            conn.close()
            return jsonify({'status': 'error', 'message': 'Student not found'}), 404

        cur.execute('''
            UPDATE Students
            SET FirstName = ?, LastName = ?, DateOfBirth = ?, Gender = ?, Address = ?, PhoneNumber = ?, Email = ?, ProgramID = ?
            WHERE StudentID = ?
        ''', (
            data['first_name'], data['last_name'], data['dob'], 
            data['gender'], data['address'], data['phone'], 
            data['email'], data['program_id'], student_id
        ))

        conn.commit()
        conn.close()
        return jsonify({'status': 'success', 'student_id': student_id})
    except Exception as e:
        conn.rollback()
        conn.close()
        return jsonify({'status': 'error', 'message': str(e)}), 400

@app.route('/api/delete_student/<int:student_id>', methods=['DELETE'])
def delete_student(student_id):
    try:
        conn = get_db()
        cur = conn.cursor()

        cur.execute('SELECT StudentID FROM Students WHERE StudentID = ?', (student_id,))
        existing = cur.fetchone()
        if not existing:
            conn.close()
            return jsonify({'status': 'error', 'message': 'Student not found'}), 404

        cur.execute('DELETE FROM Students WHERE StudentID = ?', (student_id,))
        conn.commit()
        conn.close()
        return jsonify({'status': 'success', 'message': f'Student {student_id} deleted'})
    except Exception as e:
        conn.rollback()
        conn.close()
        return jsonify({'status': 'error', 'message': str(e)}), 400

# ----------------------------
# FORM ROUTES (Pages)
# ----------------------------
@app.route('/form/enroll_student', methods=['GET'])
def form_enroll_student():
    conn = get_db()
    cur = conn.cursor()
    
    cur.execute("SELECT ProgramID, ProgramName FROM Programs ORDER BY ProgramName")
    programs = cur.fetchall()
    
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
    
    cur.execute("SELECT DepartmentID, DepartmentName FROM Departments ORDER BY DepartmentName")
    departments = cur.fetchall()
    
    conn.close()
    return render_template('add_course.html', departments=departments)

@app.route('/form/add_professor', methods=['GET'])
def form_add_professor():
    conn = get_db()
    cur = conn.cursor()
    
    cur.execute("SELECT DepartmentID, DepartmentName FROM Departments ORDER BY DepartmentName")
    departments = cur.fetchall()
    
    conn.close()
    return render_template('add_professor.html', departments=departments)

@app.route('/form/manage_students', methods=['GET'])
def manage_students():
    return render_template('manage_students.html')

# ----------------------------
# REPORT ROUTES (Pages)
# ----------------------------
@app.route('/report/department_enrollment', methods=['GET'])
def report_department_enrollment():
    return render_template('department_enrollment_report.html')

@app.route('/report/student_performance', methods=['GET'])
def report_student_performance():
    return render_template('student_performance_report.html')

# ----------------------------
# NAVIGATION
# ----------------------------
@app.route('/navigation', methods=['GET'])
def navigation():
    return render_template('navigation.html')

if __name__ == '__main__':
    app.run(debug=True)
