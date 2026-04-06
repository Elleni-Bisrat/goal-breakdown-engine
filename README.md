# Atomize — Goal Breakdown App

Atomize is a cross-platform productivity application built with **Flutter** for the frontend and **Node.js** for the backend. It helps users transform large goals into manageable daily tasks, stay organized, and track progress consistently over time.

---

## Overview

Atomize is designed to make goal achievement simpler and more structured. Instead of facing an overwhelming goal all at once, users can break it down into smaller actionable steps, monitor their progress, and stay motivated throughout the journey.

---

## Key Features

- Secure user authentication with signup and login
- Create, edit, and manage personal goals
- Automatically break goals into daily tasks
- Track task completion and overall progress
- View progress through a clean dashboard
- Receive a structured and organized task plan
- Maintain consistency with a simple productivity workflow

---

## Frontend

The frontend is built with **Flutter** and **Dart**, providing a smooth and modern mobile experience.

### Frontend Highlights
- Clean and responsive user interface
- Smooth onboarding flow
- Goal dashboard for overview and tracking
- Task management screens
- Progress visualization
- Organized project structure
- BLoC state management for scalable application logic

---

## Backend

The backend is built with **Node.js**, **Express**, and **MongoDB**.

### Backend Highlights
- RESTful API architecture
- JWT-based authentication
- Secure user session handling
- Goal and task management endpoints
- MongoDB database integration
- Modular and maintainable server-side structure

---

## Tech Stack

### Frontend
- Flutter
- Dart
- BLoC

### Backend
- Node.js
- Express.js
- MongoDB
- Mongoose
- JSON Web Token (JWT)
- bcrypt

---

## Project Vision

The vision behind Atomize is to help users achieve their goals one step at a time by turning long-term ambitions into realistic daily actions. The app is built to support consistency, focus, and measurable progress.

---

## Getting Started

### Prerequisites
Before running the project, make sure you have the following installed:

- Flutter SDK
- Node.js
- MongoDB
- Git

### Installation

#### 1. Clone the repository
```bash
git clone https://github.com/Elleni-Bisrat/goal-breakdown-engine.git
cd goal-breakdown-engine
```
2. Set up the backend
```cd backend
npm install
npm start
```
3. Set up the frontend
```cd ../frontend
flutter pub get
flutter run
```
Environment Variables

```Create a .env file in the backend directory and add your environment variables such as:
PORT=5000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_secret_key
```
Folder Structure
```
goal-breakdown-engine/
├── backend/
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── services/
│   ├── utils/
│   ├── app.js
│   └── server.js
│
└── frontend/
    ├── lib/
    ├── assets/
    ├── widgets/
    ├── screens/
    ├── blocs/
    └── main.dart
```
Future Improvements
```
AI-powered goal suggestions
Personalized task generation
Calendar and reminder integration
Dark mode support
Advanced analytics and productivity insights
Push notifications for daily task reminders
License
```
This project is intended for educational and personal productivity use. ```
