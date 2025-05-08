from flask import Blueprint, request, jsonify, render_template
from app.utils.s3_helper import upload_file_to_s3
from app.models import db, Application, Project, User, Notification
import os

application_bp = Blueprint('application', __name__)

UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@application_bp.route('/submit', methods=['GET', 'POST'])
def submit_application():
    if request.method == 'POST':
        if request.is_json:
            data = request.get_json()
            try:
                student_id = int(data.get('student_id'))
                project_id = int(data.get('project_id'))
                statement = data.get('statement_of_interest', None)
            except (TypeError, ValueError):
                return jsonify(message="❌ Invalid student_id or project_id."), 400

            project = Project.query.get(project_id)
            if not project or project.slots <= 0:
                return jsonify(message="❌ No available slots for this project."), 400

            existing = Application.query.filter_by(student_id=student_id, project_id=project_id).first()
            if existing:
                return jsonify(message="❌ You already applied to this project."), 400

            app_entry = Application(
                student_id=student_id,
                project_id=project_id,
                status="Pending",
                pdf_url=None,
                statement_of_interest=statement
            )
            project.slots -= 1
            db.session.add(app_entry)

            faculty = User.query.get(project.faculty_id)
            student = User.query.get(student_id)
            if faculty and student:
                notif = Notification(user_id=faculty.id,
                                     message=f"📨 New application from {student.name} on your project '{project.title}'")
                db.session.add(notif)

            db.session.commit()

            return jsonify(message="✅ Application submitted successfully!"), 200

        else:
            student_id = request.form.get('student_id')
            project_id = request.form.get('project_id')
            file = request.files.get('statement_file')

            if not all([student_id, project_id, file]):
                return "❌ Missing form data or file.", 400

            try:
                student_id = int(student_id)
                project_id = int(project_id)
            except ValueError:
                return "❌ Invalid student_id or project_id.", 400

            project = Project.query.get(project_id)
            if not project or project.slots <= 0:
                return "❌ No available slots for this project.", 400

            existing = Application.query.filter_by(student_id=student_id, project_id=project_id).first()
            if existing:
                return "❌ You already applied to this project.", 400

            pdf_url = upload_file_to_s3(file, f"statement_{student_id}_{project_id}.pdf")

            app_entry = Application(
                student_id=student_id,
                project_id=project_id,
                status="Pending",
                pdf_url=pdf_url,
                statement_of_interest=None
            )

            project.slots -= 1
            db.session.add(app_entry)

            faculty = User.query.get(project.faculty_id)
            student = User.query.get(student_id)
            if faculty and student:
                notif = Notification(user_id=faculty.id,
                                     message=f"📨 New application from {student.name} on your project '{project.title}'")
                db.session.add(notif)

            db.session.commit()

            return "✅ Application submitted with PDF!", 200

    return render_template('apply_project.html')


@application_bp.route('/review/faculty/<int:faculty_id>', methods=['GET', 'POST'])
def review_application(faculty_id):
    if request.method == 'POST':
        data = request.form if not request.is_json else request.get_json()
        app = Application.query.get(data['id'])

        if app:
            previous_status = app.status
            new_status = data['status']

            app.status = new_status
            app.feedback = data.get('feedback', '')

            if new_status == "Rejected" and previous_status != "Rejected":
                project = Project.query.get(app.project_id)
                if project:
                    project.slots += 1

            db.session.commit()
            return jsonify(message="Application updated!") if request.is_json else "Application updated!"

        return jsonify(message="Application not found"), 404

    applications = Application.query.join(Project).filter(Project.faculty_id == faculty_id).all()
    return render_template('review_application.html', applications=applications, faculty_id=faculty_id)


@application_bp.route('/faculty/<int:faculty_id>', methods=['GET'])
def get_faculty_applications(faculty_id):
    projects = Project.query.filter_by(faculty_id=faculty_id).all()
    project_ids = [p.id for p in projects]

    if not project_ids:
        return jsonify(message="No projects found for this faculty."), 404

    apps = Application.query.filter(Application.project_id.in_(project_ids)).all()

    response = []
    for app in apps:
        project = Project.query.get(app.project_id)
        student = User.query.get(app.student_id)
        response.append({
            "app_id": app.id,
            "student_id": app.student_id,
            "student_name": student.name if student else "Unknown",
            "project_id": app.project_id,
            "project_title": project.title if project else "Unknown",
            "status": app.status,
            "feedback": app.feedback,
            "pdf_url": app.pdf_url
        })

    return jsonify(response)


@application_bp.route('/student/<int:student_id>', methods=['GET'])
def get_student_applications(student_id):
    apps = Application.query.filter_by(student_id=student_id).all()

    response = []
    for a in apps:
        project = Project.query.get(a.project_id)
        faculty = User.query.get(project.faculty_id) if project else None
        response.append({
            "app_id": a.id,
            "project_id": a.project_id,
            "project_title": project.title if project else "N/A",
            "faculty_name": faculty.name if faculty else "Unknown",
            "status": a.status,
            "feedback": a.feedback,
            "pdf_url": a.pdf_url
        })

    return jsonify(response)
