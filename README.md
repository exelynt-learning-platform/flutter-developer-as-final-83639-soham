# PeopleDesk - Employee Management Application

A responsive Employee Management Application built using Flutter, demonstrating production-level Flutter development standards, Clean Architecture, Repository Pattern, Firebase Authentication, REST API integration, state management, and local caching.

## Features

- **Authentication & Security**
  - Email & Password sign-in / registration
  - Password reset email support
  - Google Sign-In support
  - Auth state management and protected routing
  - User profile picture and profile customization

- **Employee Management**
  - Responsive Employee Directory (Mobile Card View & Desktop/Tablet DataTable)
  - Full CRUD operations (Add, Edit, View, Delete)
  - Search employees by ID
  - Filter by Name, Email, Mobile, or Country
  - Form validation for all inputs
  - Pull-to-refresh employee directory

- **API Integration (`Dio`)**
  - Integrated REST API endpoints (`GET /employee`, `GET /employee/:id`, `POST /employee`, `PUT /employee/:id`, `DELETE /employee/:id`, `GET /country`)
  - Auto-suggest Country names fetched from API

- **Persistence & Styling**
  - Material 3 design system with Light/Dark theme toggle
  - Offline local persistence using `SharedPreferences`

- **Testing**
  - Comprehensive unit and widget test suite covering services, controllers, form validation, and UI states.

## Architecture

```
lib/
├── framework/
│   ├── controller/      # State Management (ChangeNotifier / Provider)
│   ├── model/           # Data Models & JSON Serialization
│   ├── repository/      # Repository Interface Specifications
│   └── services/        # Service Implementations (Dio REST API & Firebase)
├── ui/                  # UI Views & Components
└── main.dart            # Application Entrypoint & Dependency Injection
```

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/exelynt-learning-platform/flutter-developer-as-final-83639-soham.git
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

4. **Run tests**
   ```bash
   flutter test
   ```
