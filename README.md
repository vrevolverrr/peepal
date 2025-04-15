# 2006-FDAB-P1

# Peepal - Toilet Finder Application

## Overview
Peepal is a modern toilet finder application that helps users locate nearby toilets with detailed information and reviews. The application is built using a microservices architecture with separate frontend and backend services.

## Tech Stack

### Backend
- **Framework**: Hono (TypeScript)
- **Database**: PostgreSQL with Drizzle ORM
- **Authentication**: JWT
- **Image Storage**: MinIO
- **Testing**: Vitest
- **Validation**: Zod
- **API Documentation**: Swagger/OpenAPI

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
1. Prerequisites
   - Node.js (v18 or higher)
   - PostgreSQL
   - MinIO Server
   - pnpm (recommended)

2. Installation
```bash
cd backend
pnpm install
cp .env.example .env
# Edit .env with your configuration
pnpm run migrate
pnpm run dev
```

3. API Endpoints
   - `/api/auth/login` - User authentication
   - `/api/toilets/*` - Toilet management
   - `/api/reviews/*` - Review management
   - `/api/favorites/*` - Favorites management
   - `/api/images/*` - Image upload and retrieval

### Frontend Setup
1. Prerequisites
   - Flutter SDK
   - Xcode (iOS development)
   - Android Studio (Android development)

2. Installation
```bash
cd peepal
flutter pub get
# For iOS: cd ios && pod install
flutter run
```

## API Documentation

### Authentication
- POST `/api/auth/login` - Login user
- POST `/api/auth/register` - Register new user

### Toilets
- GET `/api/toilets/nearby` - Get nearby toilets
- POST `/api/toilets/create` - Create new toilet
- POST `/api/toilets/report/:id` - Report a toilet

### Reviews
- POST `/api/reviews/create` - Create review
- PATCH `/api/reviews/edit/:id` - Edit review
- POST `/api/reviews/report/:id` - Report review
- DELETE `/api/reviews/delete/:id` - Delete review

### Favorites
- POST `/api/favorites/add/:id` - Add to favorites
- DELETE `/api/favorites/remove/:id` - Remove from favorites
- GET `/api/favorites/me` - Get user's favorites

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

## Testing Strategy
- Unit tests for business logic
- Integration tests for API endpoints
- E2E tests for critical flows
- Test coverage for edge cases

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
MIT License
