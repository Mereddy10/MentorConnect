# app/routes/auth.py

from flask import Blueprint, request, jsonify, render_template
from app.models import db, User, UserProfile
from flask_jwt_extended import create_access_token
from werkzeug.security import generate_password_hash, check_password_hash

auth_bp = Blueprint('auth', __name__)

# ---------------------- Register Route ----------------------
@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        if request.is_json:
            data = request.get_json()
        else:
            data = request.form

        name = data.get('name')
        email = data.get('email')
        password = data.get('password')
        role = data.get('role')

        if not name or not email or not password or not role:
            return jsonify({"message": "Missing required fields"}), 400

        if User.query.filter_by(email=email).first():
            return jsonify({"message": "User already exists"}), 409

        user = User(
            name=name,
            email=email,
            role=role,
            password=generate_password_hash(password)
        )

        db.session.add(user)
        db.session.commit()

        return jsonify({"message": "Registration successful!"}), 201

    return render_template('register.html')



# ---------------------- Login Route ----------------------
@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        return render_template('login.html')

    data = request.get_json(silent=True) or request.form

    email = data.get('email')
    password = data.get('password')
    role = data.get('role')

    if not email or not password or not role:
        return jsonify({'success': False, 'message': 'Missing fields'}), 400

    user = User.query.filter_by(email=email, role=role).first()
    if user and check_password_hash(user.password, password):
        access_token = create_access_token(identity={'id': user.id, 'role': user.role})
        return jsonify({
    'success': True,
    'message': 'Login successful',
    'token': access_token,
    'user_id': user.id  # ✅ add user_id
}), 200

    else:
        return jsonify({'success': False, 'message': 'Invalid credentials'}), 401



# ---------------------- Get All Users ----------------------
@auth_bp.route('/students', methods=['GET'])
def get_students():
    students = User.query.filter_by(role='student').all()
    return jsonify([{
        "id": u.id,
        "name": u.name,
        "email": u.email
    } for u in students])

@auth_bp.route('/faculty', methods=['GET'])
def get_faculty():
    faculty = User.query.filter_by(role='faculty').all()
    return jsonify([{
        "id": u.id,
        "name": u.name,
        "email": u.email
    } for u in faculty])


# ---------------------- Update Profile ----------------------
@auth_bp.route('/profile', methods=['GET', 'POST'])
def update_profile():
    if request.method == 'GET':
        return jsonify({"message": "Profile endpoint works. Use POST to update."})

    data = request.get_json() if request.is_json else request.form

    print("\n🔵 Received DATA:")
    for k, v in data.items():
        print(f"{k}: {v}")

    user_id = data.get('user_id')
    if not user_id:
        return jsonify({"message": "❌ Missing user_id"}), 400

    user = User.query.get(user_id)
    if not user:
        return jsonify({"message": "❌ User not found"}), 404

    print(f"🔵 Detected role: {user.role}")

    profile = UserProfile.query.filter_by(user_id=user_id).first()
    if not profile:
        profile = UserProfile(user_id=user_id)

    try:
        profile.phone = data.get('phone')
        profile.address = data.get('address')
        profile.description = data.get('description')
        profile.project_titles = data.get('project_titles')
        profile.branch = data.get('branch')

        if user.role == 'student':
            profile.enrollment_no = data.get('enrollment_no')
            profile.dob = data.get('dob')
            profile.year = data.get('year')
        elif user.role == 'faculty':
            profile.faculty_id = data.get('faculty_id')
            profile.designation = data.get('designation')
            profile.experience = data.get('experience')

        user.name = data.get('name')

        db.session.add(profile)
        db.session.commit()
        print("✅ Profile saved.")
        return jsonify({"message": "✅ Profile updated!"}), 200

    except Exception as e:
        print("❌ Exception during DB commit:", str(e))
        return jsonify({"message": f"❌ Error updating profile: {str(e)}"}), 500


@auth_bp.route('/profile/<int:user_id>', methods=['GET'])
def view_profile(user_id):
    profile = UserProfile.query.filter_by(user_id=user_id).first()
    user = User.query.get(user_id)

    if not profile or not user:
        return jsonify(message="Profile not found"), 404

    return jsonify({
        "user_id": profile.user_id,
        "name": user.name,
        "email": user.email,
        "role": user.role,
        "enrollment_no": profile.enrollment_no,
        "dob": profile.dob,
        "branch": profile.branch,
        "year": profile.year,
        "phone": profile.phone,
        "address": profile.address,
        "description": profile.description,
        "project_titles": profile.project_titles,
        # 👇 Add these for faculty
        "faculty_id": profile.faculty_id,
        "designation": profile.designation,
        "experience": profile.experience
    })
