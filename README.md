# 🚀 Atomize – Goal Breakdown Engine

Atomize is a full-stack productivity application that helps users turn big goals into manageable daily tasks. It combines a **Node.js backend** with a **Flutter mobile frontend** to deliver a smooth and structured goal-tracking experience.

---

## 📱 Features

### 🔐 Authentication System

* User signup & login
* Secure password hashing (bcrypt)
* JWT-based authentication
* Protected routes

### 🎯 Goal Management

* Create, update, delete goals
* Associate goals with users
* Track multiple goals at once

### ⚙️ Task Breakdown Engine (Core Feature)

* Automatically converts big goals into daily tasks
* Generates tasks based on duration
* Assigns deadlines

### 📋 Task Management

* View tasks per goal
* Mark tasks as completed
* Update or delete tasks

### 📊 Progress Tracking

* Track completed vs total tasks
* Calculate progress percentage
* Dashboard summary

---

## 🛠️ Tech Stack

### Backend

* Node.js
* Express.js
* MongoDB (Mongoose)
* JWT Authentication
* bcrypt (password hashing)

### Frontend

* Flutter (Dart)

---

## 📂 Project Structure

```
backend/
│
├── models/
│   ├── User.js
│   ├── Goal.js
│   └── Task.js
│
├── controllers/
│   ├── authController.js
│   ├── goalController.js
│   ├── taskController.js
│   └── progressController.js
│
├── routes/
│   ├── authRoutes.js
│   ├── goalRoutes.js
│   └── taskRoutes.js
│
├── middleware/
│   ├── authMiddleware.js
│   ├── errorMiddleware.js
│   └── validationMiddleware.js
│
├── utils/
│   ├── generateToken.js
│   └── taskGenerator.js
│
└── server.js
```

---

## 🔑 API Endpoints

### Authentication

```
POST /api/auth/signup
POST /api/auth/login
GET  /api/auth/profile
```

### Goals

```
POST   /api/goals
GET    /api/goals
GET    /api/goals/:id
PUT    /api/goals/:id
DELETE /api/goals/:id
```

### Tasks

```
POST   /api/tasks/generate/:goalId
GET    /api/tasks/:goalId
PUT    /api/tasks/:id
DELETE /api/tasks/:id
PATCH  /api/tasks/:id/status
```

### Progress

```
GET /api/progress/:goalId
GET /api/dashboard
```

---

## ⚙️ Installation & Setup

### 1. Clone Repository

```bash
git clone https://github.com/your-username/atomize.git
cd atomize
```

### 2. Install Dependencies

```bash
cd backend
npm install
```

### 3. Environment Variables

Create a `.env` file in the backend folder:

```
PORT=5000
MONGO_URI=your_mongodb_connection
JWT_SECRET=your_secret_key
```

### 4. Run Server

```bash
npm run dev
```

---

## 🧪 Testing (Postman)

### Signup Example

```json
POST /api/auth/signup

{
  "name": "Sosina",
  "email": "sosina@email.com",
  "password": "123456"
}
```

### Login Example

```json
POST /api/auth/login

{
  "email": "sosina@email.com",
  "password": "123456"
}
```

### Protected Route

```
GET /api/auth/profile
Headers:
Authorization: Bearer <token>
```

---

## 📱 Flutter Integration

* Send requests using HTTP package
* Store JWT token locally (SharedPreferences)
* Include token in headers:

```
Authorization: Bearer <token>
```

---

## 🚧 Current Status

* ✅ UI Design Completed
* 🚧 Backend in Progress
* ⚠️ Authentication Fix in Progress
* 🔜 Task Automation & Dashboard

---

## 🤝 Contributors

* Sosina Ayele Nega
* Team Members (Backend Features Assigned)

---

## 💡 Future Improvements

* Notifications & reminders
* AI-powered goal suggestions
* Better analytics dashboard
* Social sharing features

---

## 📄 License

This project is open-source and available under the MIT License.

---

## ❤️ Acknowledgment

Built with passion to help people stay consistent, productive, and achieve their goals step by step.
