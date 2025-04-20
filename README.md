# 2006-FDAB-P1

# Peepal - Toilet Finder Application

## Overview
Peepal is a modern toilet finder application that helps users locate nearby toilets with detailed information and reviews. The application is built using a microservices architecture with separate frontend and backend services.

[Demo Video Link](https://youtu.be/hT4hswhUsaA)

## Tech Stack

### Backend
- **Framework**: Hono (TypeScript)
- **Database**: PostgreSQL (PostGIS) with Drizzle ORM
- **Authentication**: JWT (JSON Web Tokens)
- **Image Storage**: MinIO (Object Storage)
- **Testing**: Vitest (Unit Testing)
- **Validation**: Zod (Schema Validation)
- **Containerization**: Docker (Dockerfile)
- **Deployment**: GitHub Actions + Sevalla (CI/CD)

### Frontend
- **Framework**: Flutter
- **State Management**: BLoC Pattern
- **Navigation**: Flutter Navigation
- **UI Components**: Custom widgets with Material Design
- **Maps**: MapKit API, Google Maps API
- **Location Services**: Core Location Framework

## Architecture & Design Patterns

### Backend Architecture
1. **RESTful API Design**
   - Clean and consistent API endpoints
   - HTTP status codes for error handling
   - JSON responses with proper validation

2. **Database Design**
   - Relational database with proper indexing
   - Foreign key constraints for data integrity
   - Separate tables for users, toilets, reviews, and favorites

3. **Authentication Flow**
   - JWT-based authentication
   - Secure password hashing with bcrypt
   - Role-based access control

### Frontend Architecture
1. **BLoC Pattern**
   - Separation of concerns between UI and business logic
   - State management through BLoC classes
   - Event-driven architecture for UI updates

2. **Widget Architecture**
   - Reusable widgets for common UI components
   - Custom widgets for specific features
   - Responsive design for different screen sizes

## SOLID Principles Implementation

### Single Responsibility
- Each service (reviews, toilets, favorites) handles only its specific functionality
- Separation of database operations and business logic

### Open/Closed
- Easy extension of features through new modules
- Existing code modified only for bug fixes

### Liskov Substitution
- Proper inheritance hierarchy for database models
- Consistent behavior across different implementations

### Interface Segregation
- Clear separation of interfaces for different services
- Each service implements only what it needs

### Dependency Inversion
- Dependency injection for database connections
- Abstract interfaces for external services

## Setup Instructions

### Backend Setup
Refer to [README.md](https://github.com/softwarelab3/2006-FDAB-P1/blob/main/backend/README.md) in backend directory for guide on how to setup the backend application.

3. API Endpoints
   - `/api/auth/*` - User authentication
   - `/api/toilets/*` - Toilet management (Protected)
   - `/api/reviews/*` - Review management (Protected)
   - `/api/favorites/*` - Favorites management (Protected)
   - `/api/images/*` - Image upload and retrieval (Protected)

### Frontend Setup
1. Prerequisites
   - Flutter SDK
   - Xcode (iOS development)
   - Android Studio (Android development)

2. Installation
```bash
cd peepal
flutter pub get
flutter run
```

3. By default, the PeePal app will connect to the production backend deployed on Sevalla. To connect to the development backend, you will need to set the `kDebugMode` flag to `true` in `main.dart` to connect to `localhost:3000` or modify the `baseUrl` in the `lib/api/client.dart` file.

## API Documentation

### Authentication
- POST `/auth/login` - Login with email and password
- POST `/auth/signup` - Register new user

### Toilets
- GET `/api/toilets/` - Health check for toilets endpoint
- POST `/api/toilets/create` - Create new toilet
- PATCH `/api/toilets/details/:toiletId` - Update toilet details
- GET `/api/toilets/details/:toiletId` - Get toilet details
- POST `/api/toilets/report/:toiletId` - Report a toilet
- POST `/api/toilets/nearby` - Get nearby toilets with filtering
- POST `/api/toilets/getAddress` - Get address from coordinates
- PATCH `/api/toilets/image/:toiletId` - Update toilet image

### Reviews
- GET `/api/reviews/` - Health check for reviews endpoint
- POST `/api/reviews/create` - Create a new review
- PATCH `/api/reviews/:reviewId` - Update an existing review
- DELETE `/api/reviews/:reviewId` - Delete a review
- POST `/api/reviews/report/:reviewId` - Report a review
- GET `/api/reviews/toilet/:toiletId` - Get reviews for a toilet

### Favorites
- GET `/api/favorites/` - Health check for favorites endpoint
- GET `/api/favorites/me` - Get user's favorites
- POST `/api/favorites/add/:toiletId` - Add to favorites
- DELETE `/api/favorites/remove/:toiletId` - Remove from favorites

## External APIs & Services

### MapKit API and Google Maps API
- Used for location services and map display
- Provides real-time location updates
- Handles route calculations and directions

### MinIO
- Object storage for images
- Secure file uploads and downloads
- Handles image resizing and processing

## Security Features
- JWT-based authentication
- Password hashing with bcrypt
- Input validation with Zod
- Rate limiting for API endpoints
- Secure file uploads

