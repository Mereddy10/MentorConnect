[SRS-Mentor_Connect.pdf](https://github.com/user-attachments/files/20113008/SRS-Mentor_Connect.pdf)
# 📘 MentorConnect

MentorConnect is a cross-platform student-faculty collaboration platform developed by final-year engineering students at Mahindra University.

Designed to streamline academic project management and mentorship, MentorConnect enables a structured, transparent, and efficient digital workflow between students and faculty. From project discovery to application, meeting scheduling, and feedback, every interaction is centralized in one seamless interface.

---
## Documents
[Statement of Work (SOW).pdf](https://github.com/user-attachments/files/20113007/Statement.of.Work.SOW.pdf)
[Uploading[MentorConnect_SDD.pdf](https://github.com/user-attachments/files/20113009/MentorConnect_SDD.pdf)
SRS-Mentor_Connect.pdf…]()

## ✨ Key Features & Descriptions

### Key Features
JWT Authentication – Secure login with role-based access for students and faculty.

Project Management – Faculty can post projects; students can apply with PDF-based SOI.

Slot Handling – Auto-disables applications once project slots are filled.

Application Review – Faculty can accept, reject, or give feedback on student applications.

Meeting Scheduler – Students can request meetings; faculty can respond or reschedule.

In-App Notifications – Real-time alerts for applications, meetings, and updates.

User Profiles – Dedicated profiles showing academic and personal info.

AWS S3 Integration – Secure cloud storage for SOIs and reports.

Smart UI Logic – Prevents duplicate actions; real-time feedback with disabled buttons.

Clean Role-Based Interface – Users only see relevant features based on their role.

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

### Frontend Setup
- cd mentorconnect
- flutter pub get
- flutter run

### Backend Setup (Flask + AWS S3 + SQLite)
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

## 👨‍💻 Team Members & Contributions

| Name                  | Roll No         | Contribution Description                                  |
|-----------------------|-----------------|-----------------------------------------------------------|
| Mereddy Sahasra       | SE22UCSE169     | Frontend & Backend (S3 upload, dashboards)                |
| Marepally Mahathi     | SE22UCSE163     | Backend (API testing, meetings, models)                   |
| Eega Akshasreee       | SE22UCSE318     | Backend (notifications, projects, HTML logic)             |
| Kaluva Dishitha       | SE22UCSE322     | Frontend Integration (Login/Welcome/Register screens)     |
| Kota Deekshitha       | SE22UCSE142     | Project-related frontend                                  |
| B Shriya Reddy        | SE22UCSE045     | Meeting-related frontend                                  |
| Devidi Snehitha Reddy | SE22UCSE079     | Notification & profile screens frontend                   |




