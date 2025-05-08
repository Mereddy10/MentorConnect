
# 📘 MentorConnect

MentorConnect is a comprehensive student-faculty project management app designed for Mahindra University. It simplifies project allocation, application tracking, file submission, and meeting scheduling. Built using **Flutter (frontend)**, **Flask (backend)**, **AWS S3 (document storage)**, and **PostgreSQL/MySQL (database)**, the system supports seamless collaboration and communication.

---

## ✨ Key Features & Descriptions

### 🔑 User Authentication (JWT-Based)
Secure login system for both students and faculty with role-based access:
- Students can access application and scheduling features.
- Faculty can manage projects and review student actions.

---

### 🎓 Student Module

1. **View Projects**  
   Browse all available faculty-posted projects. Each listing includes title, description, and available slots.

2. **Apply for Projects**  
   Students can apply for projects by submitting a brief proposal or statement of interest. Reapplication is disabled once applied.

3. **Document Upload**  
   Upload project proposals and progress reports securely to AWS S3. Faculty can view and provide feedback.

4. **Meeting Scheduling**  
   Request meetings with selected faculty. Students choose available slots from a calendar-based UI.

5. **Notifications**  
   Receive real-time alerts for:
   - Application status (approved/rejected)
   - Feedback updates
   - Meeting reminders

6. **View Meeting Status**  
   Students can check meeting details, reschedules, and faculty feedback.

7. **Profile Management**  
   Edit name, branch, CGPA, email, phone number, and DOB in your profile section.

---

### 👨‍🏫 Faculty Module

1. **Post Projects**  
   Faculty can post new project topics, define the number of available slots, and add descriptions and prerequisites.

2. **Manage Applications**  
   View students who have applied to your projects. Approve, reject, or request more info with one click.

3. **Upload Feedback on Documents**  
   View student-submitted PDFs (proposal/reports) and share feedback or comments.

4. **Respond to Meeting Requests**  
   Accept, reject, or reschedule meeting requests. The system prevents multiple responses.

5. **Mark Projects as Allocated**  
   When all slots are filled, the system automatically disables the "Apply" button and shows "Already Applied."

6. **Notifications**  
   Receive alerts when a student applies for a project or schedules a meeting.

7. **Faculty Profile**  
   Faculty can update designation, experience, email, and view students under their mentorship.

---


---

## 🚀 Setup Instructions

### 1. Clone the repository

- git clone https://github.com/Mereddy10/mentorconnect.git
- cd mentorconnect

###Frontend Setup
- cd mentorconnect
- flutter pub get
- flutter run

###Backend Setup (Flask + AWS S3 + SQLite)
- cd mentor_connect_backend
- pip install -r requirements.txt
- python3 run.py

## ☁️ Technologies Used

| Layer         | Tech Stack                               |
|---------------|------------------------------------------|
| Frontend      | Flutter                                  |
| Backend       | Flask                                    |
| Database      | SQLite                                   |
| Storage       | AWS S3                                   |
| Auth          | JWT (JSON Web Tokens)                    |
| Notifications | Firebase Cloud Messaging (FCM)           |


## 👥 Team

Developed by the MentorConnect Team @ Mahindra University

| Name                   | Roll No       | Email                                        | Contributions                         |
|------------------------|---------------|----------------------------------------------|---------------------------------------|
| B Shriya Reddy         | SE22UCSE045   | se22ucse045@mahindrauniversity.edu.in        | UI Design, Flutter Development        |
| Devidi Snehitha Reddy  | SE22UCSE079   | se22ucse079@mahindrauniversity.edu.in        | Backend Integration, API Handling     |
| Kota Deekshitha        | SE22UCSE142   | se22ucse142@mahindrauniversity.edu.in        | Database Design, Testing              |
| Marepally Mahathi      | SE22UCSE163   | se22ucse163@mahindrauniversity.edu.in        | Documentation, UI Testing             |
| Mereddy Sahasra        | SE22UCSE169   | se22ucse169@mahindrauniversity.edu.in        | Full Stack Dev, AWS, Notification Sys |
| Eega Akshasreee        | SE22UCSE318   | se22ucse318@mahindrauniversity.edu.in        | Frontend Support, User Flow Design    |
| Kaluvai Dishitha       | SE22UCSE322   | se22ucse322@mahindrauniversity.edu.in        | Project Coordination, Testing Support |



