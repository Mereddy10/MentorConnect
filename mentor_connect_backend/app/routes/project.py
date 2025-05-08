from flask import Blueprint, request, jsonify, render_template
from app.models import db, Project, User, Notification  # ✅ Added Notification model

project_bp = Blueprint('project', __name__)

# 📌 Route to post a new project with slot count
@project_bp.route('/post', methods=['GET', 'POST'])
def post_project():
    if request.method == 'POST':
        data = request.get_json()
        if not data:
            return jsonify({"message": "No data received"}), 400

        faculty_id = data.get("faculty_id")
        faculty_name = data.get("faculty_name")
        title = data.get("title")
        description = data.get("description")
        slots = data.get("slots")

        if not all([faculty_id, title, description, slots]):
            return jsonify({"message": "Missing fields"}), 400

        # ✅ Create new project
        new_project = Project(
            faculty_id=faculty_id,
            faculty_name=faculty_name,
            title=title,
            description=description,
            slots=slots
        )

        db.session.add(new_project)
        db.session.commit()

        # ✅ Send notifications to all students
        # 👉 File: project.py
        # 👉 Location: Inside the route where the project is created (after saving project to DB)
        students = User.query.filter_by(role='student').all()
        faculty = User.query.get(faculty_id)
        for s in students:
            notif = Notification(
                user_id=s.id,
                message=f"📢 New project '{new_project.title}' posted by {faculty.name if faculty else 'a faculty member'}"
            )
            db.session.add(notif)
        db.session.commit()

        return jsonify({"message": "✅ Project posted successfully"}), 200

    return render_template('post_project.html')


# 📌 Route to get all projects
@project_bp.route('/all', methods=['GET'])
def get_all_projects():
    projects = Project.query.all()
    project_list = []

    for p in projects:
        faculty = User.query.get(p.faculty_id)
        project_list.append({
            'id': p.id,
            'title': p.title,
            'description': p.description,
            'slots': p.slots,
            'faculty_id': p.faculty_id,
            'faculty_name': faculty.name if faculty else "Unknown",
            'is_available': p.is_available
        })

    return jsonify(project_list)


# 📌 Route to get only available projects with faculty name
@project_bp.route('/available', methods=['GET'])
def get_available_projects():
    projects = Project.query.filter_by(is_available=True).all()
    project_list = []

    for p in projects:
        faculty = User.query.get(p.faculty_id)
        project_list.append({
            'id': p.id,
            'title': p.title,
            'description': p.description,
            'slots': p.slots,
            'faculty_id': p.faculty_id,
            'faculty_name': faculty.name if faculty else "Unknown"
        })

    return jsonify(project_list)


# 📌 HTML view for available projects
@project_bp.route('/available/view')
def view_available_projects():
    return render_template('available_projects.html')
