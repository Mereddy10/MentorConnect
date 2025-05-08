from flask import Blueprint, request, jsonify, render_template
from app.models import db, Meeting, User, Project, Notification

meeting_bp = Blueprint('meeting', __name__)

# 📌 1. Student schedules a meeting
@meeting_bp.route('/schedule', methods=['GET', 'POST'])
def schedule_meeting():
    if request.method == 'POST':
        data = request.form if not request.is_json else request.get_json()

        meeting = Meeting(
            student_id=data['student_id'],
            faculty_id=data['faculty_id'],
            date=data['date'],
            time=data['time'],
            time_format=data.get('time_format', 'AM'),
            description=data.get('description'),
            status='Pending'
        )

        db.session.add(meeting)

        faculty = User.query.get(data['faculty_id'])
        student = User.query.get(data['student_id'])
        if faculty and student:
            notif = Notification(user_id=faculty.id, message=f"🗕️ {student.name} has requested a meeting.")
            db.session.add(notif)

        db.session.commit()
        return jsonify(message="✅ Meeting scheduled!") if request.is_json else "Meeting scheduled!"

    return render_template('schedule_meeting.html')


# 📌 2. Faculty views & responds to meetings
@meeting_bp.route('/faculty/<int:faculty_id>', methods=['GET', 'POST'])
def faculty_meetings(faculty_id):
    if request.method == 'POST':
        data = request.form if not request.is_json else request.get_json()
        meeting_id = int(data['meeting_id'])
        status = data['status']
        mode = data.get('mode')
        new_date = data.get('new_date')
        new_time = data.get('new_time')
        time_format = data.get('time_format')
        message = data.get('message')

        meeting = Meeting.query.get(meeting_id)
        faculty = User.query.get(faculty_id)

        if meeting:
            if meeting.status in ['Accepted', 'Rejected']:
                return jsonify(message="⚠️ Meeting already finalized."), 400

            meeting.status = status
            if status == 'Accepted':
                meeting.mode = mode
            elif status == 'Reschedule':
                meeting.date = new_date
                meeting.time = new_time
                meeting.time_format = time_format
                meeting.faculty_message = message
            elif status == 'Rejected':
                meeting.faculty_message = message

            student = User.query.get(meeting.student_id)
            if student and faculty:
                msg = f"✅ Your meeting has been {status.lower()} by {faculty.name}."
                notif = Notification(user_id=student.id, message=msg)
                db.session.add(notif)

            db.session.commit()
            return jsonify(message="✅ Meeting response updated successfully!")

    meetings = Meeting.query.filter_by(faculty_id=faculty_id).all()

    if request.is_json or 'application/json' in request.headers.get('Accept', ''):
        meeting_details = []
        for m in meetings:
            student = User.query.get(m.student_id)
            project = Project.query.get(m.project_id) if m.project_id else None
            meeting_details.append({
                'id': m.id,
                'student_id': m.student_id,
                'student_name': student.name if student else "Unknown",
                'project_id': m.project_id,
                'project_title': project.title if project else "Not Assigned Yet",
                'description': m.description or "No description provided",
                'date': m.date,
                'time': m.time,
                'time_format': m.time_format,
                'status': m.status,
                'mode': m.mode,
                'new_date': m.new_date,
                'new_time': m.new_time,
                'faculty_message': m.faculty_message,
                'faculty_id': m.faculty_id
            })
        return jsonify(meeting_details), 200

    enriched_meetings = []
    for m in meetings:
        student = User.query.get(m.student_id)
        project = Project.query.get(m.project_id) if m.project_id else None
        enriched_meetings.append({
            'id': m.id,
            'student_id': m.student_id,
            'student_name': student.name if student else 'Unknown',
            'project_title': project.title if project else 'Not Assigned Yet',
            'description': m.description or "No description provided",
            'faculty_id': m.faculty_id,
            'date': m.date,
            'time': m.time,
            'time_format': m.time_format,
            'status': m.status
        })

    return render_template('faculty_meetings.html', meetings=enriched_meetings)


# 📌 3. Student views their meeting status
@meeting_bp.route('/student/<int:student_id>', methods=['GET'])
def student_meetings(student_id):
    meetings = Meeting.query.filter_by(student_id=student_id).all()

    if request.is_json or 'application/json' in request.headers.get('Accept', ''):
        result = []
        for m in meetings:
            faculty = User.query.get(m.faculty_id)
            project = Project.query.get(m.project_id) if m.project_id else None
            result.append({
                'meeting_id': m.id,
                'faculty_name': faculty.name if faculty else 'Unknown',
                'project_title': project.title if project else 'No Project',
                'description': m.description or "No description provided",
                'date': m.date,
                'time': m.time,
                'status': m.status,
                'mode': m.mode,
                'new_date': m.new_date,
                'new_time': m.new_time,
                'feedback': m.faculty_message,
            })
        return jsonify(result), 200

    return render_template('student_meetings.html', meetings=meetings)


# 📌 4. GET list of all faculty with their projects
@meeting_bp.route('/faculty/list', methods=['GET'])
def get_faculty_list():
    faculty = User.query.filter_by(role='faculty').all()
    data = []
    for f in faculty:
        project = Project.query.filter_by(faculty_id=f.id).first()
        title = project.title if project else "No Project Assigned"
        data.append({
            "id": f.id,
            "name": f"{f.name} - {title}"
        })
    return jsonify(data)

