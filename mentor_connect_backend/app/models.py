from datetime import datetime
from app import db
from app.extensions import db
from datetime import datetime


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)
    role = db.Column(db.String(20), nullable=False)  # 'student' or 'faculty'


class Project(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(120), nullable=False)
    description = db.Column(db.Text, nullable=False)
    slots = db.Column(db.Integer, nullable=False)
    is_available = db.Column(db.Boolean, default=True)
    faculty_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    faculty_name = db.Column(db.String(100), nullable=False)


class Application(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    student_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    project_id = db.Column(db.Integer, db.ForeignKey('project.id'))
    status = db.Column(db.String(20), default='Pending')  # 'Pending', 'Approved', 'Rejected'
    feedback = db.Column(db.String(300), default='')
    pdf_url = db.Column(db.Text) 
    statement_of_interest = db.Column(db.Text)


class Meeting(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    student_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    faculty_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    description = db.Column(db.Text)
    project_id = db.Column(
    db.Integer,
    db.ForeignKey('project.id', name='fk_meeting_project'),
    nullable=True
    
)
 # ⬅️ ADD THIS LINE
    date = db.Column(db.String(20), nullable=False)
    time = db.Column(db.String(20), nullable=False)
    time_format = db.Column(db.String(10), default='AM')
    status = db.Column(db.String(20), default='Pending')
    mode = db.Column(db.String(20))
    faculty_message = db.Column(db.Text)
    new_date = db.Column(db.String(20))
    new_time = db.Column(db.String(20))


class UserProfile(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), unique=True)
    enrollment_no = db.Column(db.String(50))
    dob = db.Column(db.String(20))
    branch = db.Column(db.String(50))
    year = db.Column(db.String(10))
    phone = db.Column(db.String(20))
    address = db.Column(db.Text)
    description = db.Column(db.Text)
    project_titles = db.Column(db.Text)  # store like "Title 1, Title 2"
    faculty_id = db.Column(db.String(50))
    designation = db.Column(db.String(100))
    experience = db.Column(db.String(100))

    user = db.relationship('User', backref='profile', uselist=False)

class Notification(db.Model):
    __tablename__ = 'notification'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(
        db.Integer,
        db.ForeignKey('user.id', name='fk_notification_user_id'),  # ✅ name the FK
        nullable=False
    )
    message = db.Column(db.String(255), nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
