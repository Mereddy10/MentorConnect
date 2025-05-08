from flask import Flask
from app.extensions import db, migrate, jwt  # ✅ Centralized extensions
from flask_cors import CORS
from dotenv import load_dotenv
import os

# Blueprints
from app.routes.auth import auth_bp
from app.routes.project import project_bp
from app.routes.application import application_bp
from app.routes.meeting import meeting_bp
from app.routes.notification import notification_bp

def create_app():
    load_dotenv()

    app = Flask(__name__)
    
    # ✅ Configuration
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///mentor.db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['JWT_SECRET_KEY'] = os.getenv("JWT_SECRET_KEY", "default_secret_key")  # Ensure .env is configured

    # ✅ Initialize extensions
    CORS(app)
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)

    # ✅ Register Blueprints
    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(project_bp, url_prefix='/project')
    app.register_blueprint(application_bp, url_prefix='/application')
    app.register_blueprint(meeting_bp, url_prefix='/meeting')
    app.register_blueprint(notification_bp)
    

    # ✅ Basic Test Routes
    @app.route('/')
    def home():
        return "Flask is working!"

    @app.route('/test')
    def test_template():
        from flask import render_template
        return render_template('test.html')

    return app
