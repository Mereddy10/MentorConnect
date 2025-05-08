# app/routes/notification.py

from flask import Blueprint, jsonify, request
from app.models import db, Notification

notification_bp = Blueprint('notification', __name__)

# 🟢 GET all notifications for a user
@notification_bp.route('/notifications/<int:user_id>', methods=['GET'])
def get_notifications(user_id):
    notifications = Notification.query.filter_by(user_id=user_id).order_by(Notification.timestamp.desc()).all()
    return jsonify([
        {
            "id": n.id,
            "message": n.message,
            "timestamp": n.timestamp.strftime('%Y-%m-%d %H:%M')
        } for n in notifications
    ])
