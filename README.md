# Smart Habit Tracker (Habit Forge)

Smart Habit Tracker (Habit Forge) is a full-stack application built using Flutter, Node.js, Express, and MongoDB.  
The app helps users build consistency by tracking daily and weekly habits, logging completions, and viewing simple progress statistics.

This project was built as part of a full-stack assignment and focuses on clean architecture, correct backend logic, and a polished, minimal UI.

---

## Features

### Authentication
- User registration and login
- Password hashing using bcrypt
- Email uniqueness enforced
- Simple session handling (no JWT)
- Auto-login using local storage
- Logout support

### Habit Management
- Create, edit, archive, and delete habits
- Support for daily and weekly habits
- Filter habits by active or archived status

### Habit Tracking
- Mark habits as completed for specific dates
- Toggle completion (mark / unmark)
- Habit completion logs stored in the database

### Statistics
- Total days tracked per habit
- Days completed
- Completion rate percentage

### UI / UX
- Clean and minimal design
- Consistent theming and spacing
- Keyboard-safe forms
- Visual indicators for completed habits
- Responsive layouts

---

## Tech Stack

### Frontend
- Flutter
- Material 3
- HTTP
- shared_preferences

### Backend
- Node.js
- Express.js
- MongoDB
- Mongoose
- bcrypt
- dotenv

---

## Project Structure

habit-tracker/
- backend/
  - app.js
  - package.json
  - .env.example
  - config/
    - db.js
  - models/
    - User.js
    - Habit.js
    - HabitLog.js
  - routes/
    - authRoutes.js
    - habitRoutes.js
  - middleware/
    - logger.js
    - validateFields.js
  - api-tests/
- frontend/
  - pubspec.yaml
  - lib/
    - main.dart
    - screens/
    - widgets/
    - services/
    - theme/

---

## Environment Variables

Create a `.env` file inside the backend directory with the following variables:

MONGO_URL=your_mongo_connection_string  
PORT=5000  

The file is provided as `.env.example`.

---

## How to Run the Project

### Input URL into /fronted/lib/services/habit_service.dart and /auth_service.dart on line 5.
![services](/screenshots/auth_service.png)
![service](/screenshots/habit_service.png)

### Backend

1. Navigate to the backend folder  
2. Install dependencies  
3. Start the server  

Commands:

npm install  
npm run dev  

---

### Frontend

1. Navigate to the frontend folder  
2. Install Flutter dependencies  
3. Run the app  

Commands:

flutter pub get  
flutter run  

---

## API Testing

All major API endpoints were tested using Postman or Thunder Client.

Tested endpoints include:
- Register
- Login
- Create habit
- Get habits
- Update habit
- Delete habit
- Mark habit
- Get logs
- Get statistics

Screenshots are included separately in screenshots.md.

---

## Screenshots

Application and API testing screenshots are provided in the screenshots documentation file.

---

## Author - Dhruvin

This project was built to demonstrate:
- Backend API development
- Database modeling with MongoDB
- Flutter UI development
- Full-stack integration
- Clean architecture and UX principles