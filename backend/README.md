# Goal Tracking Backend API

## Project Overview

This project is a Node.js, Express, and MongoDB backend API designed to help users set goals, break them into daily tasks, and track their progress.

---

## What This Project Does

* User authentication (signup and login)
* Goal creation and management
* Automatic task generation from goals
* Task management (update, delete, complete)
* Progress tracking and dashboard statistics

---

## What You Will Learn

* JWT-based authentication
* Password hashing with bcrypt
* REST API design
* MongoDB schema design using Mongoose
* Middleware usage (authentication, validation, error handling)
* Backend project structure and organization

---

## Tech Stack

* Node.js
* Express.js
* MongoDB
* Mongoose
* JSON Web Token (JWT)
* bcrypt

---

## Project Structure

```
project-root/
│-- models/
│-- controllers/
│-- routes/
│-- middleware/
│-- utils/
│-- config/
│-- app.js
│-- package.json
│-- README.md
```

---

## Installation and Run

```
npm install
npm run dev
```

Or:

```
npm start
```

---

## Environment Variables

Create a .env file in the root directory:

```
PORT=5000
MONGO_URI=your_mongodb_uri
JWT_SECRET=your_secret_key
```

---

## Authentication Flow

1. User signs up or logs in using email and password
2. Password is hashed using bcrypt before storing
3. On login, password is verified
4. A JWT token is generated
5. Protected routes require a valid token

---

## API Endpoints

### Auth Routes

```
POST   /api/auth/signup
POST   /api/auth/login
GET    /api/auth/profile
```

### Goal Routes

```
POST   /api/goals
GET    /api/goals
GET    /api/goals/:id
PUT    /api/goals/:id
DELETE /api/goals/:id
```

### Task Routes

```
POST   /api/tasks/generate/:goalId
GET    /api/tasks/:goalId
PUT    /api/tasks/:id
DELETE /api/tasks/:id
PATCH  /api/tasks/:id/status
```

### Progress Routes

```
GET /api/progress/:goalId
GET /api/dashboard
```

---

## Core System Flow

1. Goal Creation
   User creates a goal with a duration 

2. Task Generation
   The system automatically generates daily tasks based on the goal duration

3. Task Management
   Users can update, delete, or mark tasks as completed

4. Progress Tracking
   The system calculates total tasks, completed tasks, and completion percentage

---

## Example Response

```
{
  "totalTasks": 30,
  "completedTasks": 18,
  "progress": 60
}
```

---


