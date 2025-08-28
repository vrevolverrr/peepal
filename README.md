# PeePal - Full Stack Toilet Locator and Navigation App

[![Live Demo](https://img.shields.io/badge/🌐%20Live%20Demo-Youtube-blue?style=for-the-badge)](https://youtu.be/hT4hswhUsaA)
[![Backend Status](https://img.shields.io/website?down_color=red&down_message=offline&up_color=green&up_message=online&url=https%3A//peepal-backend-deployment-z0st0.kinsta.app/auth&style=for-the-badge&label=Backend&logo=hono)](https://peepal-backend-deployment-z0st0.kinsta.app/)
[![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)

> **A modern, full-stack toilet finder application serving Singapore with real-time location services, crowdsourced data, and intelligent geospatial search capabilities.**

---


https://github.com/user-attachments/assets/ea3afcef-89ea-4ca2-b3c4-63844832a685


## Problem & Solution

**The Challenge**: Finding accessible, clean public toilets in urban environments is a universal problem, especially for travelers, elderly, disabled individuals, and families with young children.

**Our Solution**: PeePal transforms toilet discovery through:
- **Real-time geospatial search** using advanced PostGIS technology
- **Crowdsourced data** with community-driven reviews and ratings
- **Smart filtering** by amenities (wheelchair accessible, bidet, shower, sanitizer)
- **Intelligent auto-moderation** system for data quality
- **Turn-by-turn navigation** with Apple MapKit integration

---

## What Makes This Project Special

### **Advanced Geospatial Computing**
- **PostGIS integration** for efficient spatial queries and indexing
- **Real-time location processing** with radius-based toilet discovery
- **Geocoding & reverse geocoding** for address resolution
- **Route optimization** using Apple MapKit APIs

### **Production-Grade Architecture**
- **Microservices design** with clear separation of concerns
- **Type-safe APIs** with comprehensive Zod validation
- **JWT-based authentication** with secure password hashing
- **Auto-scaling database** with proper indexing and constraints
- **Docker containerization** with multi-stage builds

### **Modern Mobile Development**
- **BLoC pattern** for clean state management architecture
- **Repository pattern** for data abstraction
- **Custom UI components** with Material Design principles
- **Responsive design** across different screen sizes
- **Real-time updates** with optimistic UI patterns

### **Enterprise Security Standards**
- **bcrypt password hashing** with secure salt generation
- **JWT token management** with proper expiration
- **Input sanitization** and SQL injection prevention
- **Rate limiting** and DDoS protection
- **Secure file uploads** with MinIO object storage

---

## Tech Stack & Architecture

### **Backend Infrastructure**
```typescript
Framework       │ Hono (TypeScript) - High-performance web framework
Database        │ PostgreSQL + PostGIS for geospatial data
ORM            │ Drizzle ORM - Type-safe database operations  
Authentication │ JWT with bcrypt password hashing
File Storage   │ MinIO (S3-compatible) object storage
Testing        │ Vitest for unit & integration testing
Validation     │ Zod schemas for runtime type checking
Deployment     │ Docker + GitHub Actions CI/CD
```

### **Frontend Architecture**
```dart
Framework       │ Flutter (Dart) - Cross-platform development
State Mgmt     │ BLoC Pattern - Reactive programming
Maps           │ Apple Maps (MapKit) - Native iOS integration
UI Components  │ Custom Material Design + Cupertino widgets
HTTP Client    │ Dio - Powerful HTTP client with interceptors
Local Storage  │ SharedPreferences for caching
```

### **External Integrations**
```
Apple MapKit API    │ Real-time location & navigation services
Google Maps API     │ Additional geocoding capabilities  
MinIO Storage      │ Scalable image upload & processing
Geolocator         │ GPS positioning with high accuracy
```

---

## System Architecture & Design Patterns

### **Backend Architecture Highlights**

#### **Resource-Oriented API Design**
```typescript
// Clean RESTful endpoints with semantic HTTP methods
GET    /api/toilets/nearby     // Geospatial search with filters
POST   /api/toilets/create     // Add new toilet location
PATCH  /api/toilets/:id        // Update existing toilet
DELETE /api/favorites/:id      // Remove from favorites
```

#### **Middleware Pipeline**
```typescript
Request → CORS → Logger → Validator → Auth → Route Handler → Response
```

#### **Database Schema Excellence**
```sql
-- Geospatial indexing for performance
CREATE INDEX toilets_location_idx ON toilets USING GIST(location);

-- Foreign key constraints for data integrity
ALTER TABLE reviews ADD CONSTRAINT fk_toilet 
  FOREIGN KEY (toilet_id) REFERENCES toilets(id);
```

#### **JWT Authentication Flow**
```typescript
// Secure token generation with user context
const token = jwt.sign({ userId, email }, SECRET, { 
  expiresIn: '24h',
  algorithm: 'HS256' 
});
```

### **Frontend Architecture Excellence**

#### **BLoC State Management**
```dart
// Clean separation of business logic and UI
class ToiletsBloc extends Bloc<ToiletEvent, ToiletState> {
  ToiletsBloc(this._repository) : super(ToiletInitial()) {
    on<LoadNearbyToilets>(_onLoadNearbyToilets);
    on<FilterToilets>(_onFilterToilets);
  }
}
```

#### **Widget Architecture**
```dart
// Reusable, composable UI components
class ToiletCard extends StatelessWidget {
  final Toilet toilet;
  final VoidCallback onTap;
  
  // Custom widget with Material Design principles
}
```

---

## Key Technical Achievements

### **Performance & Scalability**
- **Spatial indexing** reduces query time from seconds to milliseconds
- **Efficient state management** with BLoC pattern prevents unnecessary rebuilds
- **Image optimization** with automatic resizing and compression
- **Database connection pooling** for high concurrent user support
- **Responsive caching** strategies for offline functionality

### **Advanced Geospatial Features**
- **PostGIS spatial queries** for accurate distance calculations
- **Real-time location tracking** with GPS accuracy optimization
- **Dynamic radius search** with customizable distance filters
- **Route calculation** with turn-by-turn navigation
- **Address geocoding** for human-readable location display

### **Security & Data Integrity**
- **Automatic content moderation** with report-based deletion (3+ reports)
- **SQL injection prevention** through parameterized queries
- **Password security** with industry-standard bcrypt hashing
- **Input validation** at API boundary with Zod schemas
- **Secure file uploads** with type validation and virus scanning

### **Smart Data Management**
- **Crowdsourced data quality** through community reviews
- **Automated cleanup** of stale or reported content  
- **Review aggregation** with weighted rating calculations
- **Favorites synchronization** across devices
- **Offline data caching** for poor network conditions

---

## Development Quality & Best Practices

### **Testing & Quality Assurance**
```typescript
// Comprehensive test coverage
├── Unit Tests        │ Business logic validation
├── Integration Tests │ API endpoint testing  
├── End-to-end Tests  │ Complete user workflows
└── Database Tests    │ Data integrity verification
```

### **CI/CD Pipeline**
```yaml
# Automated deployment workflow
Build → Test → Security Scan → Deploy → Health Check → Rollback Ready
```

### **Code Quality Standards**
- **TypeScript strict mode** for compile-time safety
- **ESLint & Prettier** for consistent code formatting
- **Conventional commits** for clear git history
- **Code review process** with PR templates
- **Documentation** with inline comments and README

### **Security Best Practices**
- **Environment variable management** for sensitive data
- **CORS configuration** for controlled access
- **Rate limiting** to prevent abuse
- **HTTPS enforcement** across all endpoints
- **Dependency vulnerability scanning**

---

## Key Features Showcase

### **Intelligent Search & Discovery**
- Find toilets within customizable radius (100m - 5km)
- Advanced filtering by amenities and accessibility features
- Real-time availability and crowd level indicators
- Smart sorting by distance, rating, and user preferences

### **Community-Driven Platform**
- User-generated reviews with photo uploads
- Star ratings with weighted algorithms
- Community moderation through reporting system
- Crowdsourced toilet location submissions

### **Navigation & Accessibility**
- Turn-by-turn walking directions
- Wheelchair accessibility indicators
- Public transport integration
- Offline map caching for areas with poor connectivity

### **Personalization & Sync**
- Personal favorites list with cloud sync
- User preference learning for better recommendations  
- Cross-device data synchronization
- Customizable notification settings

---

## Quick Start Guide

### **Backend Setup**
```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your database and API keys

# Setup database
npm run generate  # Generate migrations
npm run migrate   # Apply migrations
npm run seed      # Seed with initial data

# Start development server
npm run dev       # http://localhost:3000
```

### **Frontend Setup**
```bash
# Navigate to Flutter app
cd peepal

# Install dependencies
flutter pub get

# Run on iOS Simulator
flutter run

# Build for production
flutter build ios
```

---

## API Documentation

### **Authentication Endpoints**
```http
POST /auth/signup    # User registration
POST /auth/login     # User authentication
```

### **Toilet Management**
```http
POST /api/toilets/nearby      # Geospatial search
POST /api/toilets/create      # Add new toilet
GET  /api/toilets/:id         # Get toilet details
PATCH /api/toilets/:id        # Update toilet info
POST /api/toilets/report/:id  # Report toilet issue
```

### **Reviews & Ratings**
```http
POST /api/reviews/create      # Add review
GET  /api/reviews/toilet/:id  # Get toilet reviews
PATCH /api/reviews/:id        # Update review
DELETE /api/reviews/:id       # Delete review
POST /api/reviews/report/:id  # Report inappropriate review
```

### **User Favorites**
```http
GET  /api/favorites/me        # Get user favorites
POST /api/favorites/add/:id   # Add to favorites
DELETE /api/favorites/remove/:id # Remove favorite
```

---

## Technical Highlights

### **Why This Architecture Matters**

1. **Scalability**: Microservices design allows independent scaling of components
2. **Maintainability**: Clean separation of concerns with SOLID principles
3. **Performance**: PostGIS spatial indexing provides sub-100ms query times
4. **Security**: Enterprise-grade authentication and data protection
5. **Extensibility**: Plugin architecture for easy feature additions
6. **Testing**: Comprehensive test coverage ensures reliability
7. **DevOps**: Automated CI/CD pipeline reduces deployment risks

### **Industry-Standard Patterns Implemented**
- Repository Pattern for data access abstraction
- BLoC Pattern for predictable state management  
- Middleware Pattern for cross-cutting concerns
- Observer Pattern for real-time UI updates
- Factory Pattern for object creation
- Dependency Injection for loose coupling

---

## About This Project

This project demonstrates expertise in **full-stack development**, **system architecture**, **database design**, **mobile development**, and **DevOps practices**. Built with production-ready code quality, comprehensive testing, and enterprise security standards.

**Technical Skills Showcased:**
- Full-Stack TypeScript Development
- Flutter Mobile App Development  
- PostgreSQL & PostGIS Geospatial Computing
- RESTful API Design & Implementation
- JWT Authentication & Security
- Docker Containerization & Deployment
- CI/CD Pipeline Setup
- Database Design & Optimization
- State Management Architecture
- Testing & Quality Assurance

---

<div align="center">

**Built by Bryan Soong, Adam Soh, Joyce Lee, Liew Jia Wei, Joshua Tan**

*Transforming everyday problems into elegant technical solutions*

</div>
