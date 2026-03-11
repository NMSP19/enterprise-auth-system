# Enterprise Authentication & Authorization System

[![Java](https://img.shields.io/badge/Java-17+-brightgreen.svg)](https://www.java.com)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Angular](https://img.shields.io/badge/Angular-18+-red.svg)](https://angular.io)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12+-blue.svg)](https://www.postgresql.org)
[![JWT](https://img.shields.io/badge/Auth-JWT-yellow.svg)](https://jwt.io)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A production-grade authentication and authorization system demonstrating enterprise-level security practices. Built with **Spring Boot**, **Angular**, and **PostgreSQL**, this project showcases real-world authentication patterns used by leading tech companies.

## 📋 Quick Navigation

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Quick Start](#quick-start)
- [Setup Guide](#setup-guide)
- [API Endpoints](#api-endpoints)
- [Architecture](#architecture)
- [Documentation](#documentation)

---

## ✨ Features

### Authentication
- ✅ JWT token-based authentication (stateless)
- ✅ Access token (15 min) + Refresh token (7 days)
- ✅ Session timeout and idle detection
- ✅ Secure login/logout

### Authorization
- ✅ Role-Based Access Control (RBAC)
- ✅ Multiple user roles (Admin, User, Manager)
- ✅ Permission-based endpoint protection
- ✅ Fine-grained access control

### Security
- ✅ BCrypt password hashing
- ✅ JWT signature validation
- ✅ CORS protection
- ✅ Spring Security integration
- ✅ No server-side sessions (stateless)

---

## 🛠️ Tech Stack

**Backend**: Java 17 | Spring Boot 3.2 | Spring Security 6 | JWT | PostgreSQL | Maven

**Frontend**: Angular 18 | TypeScript 5 | RxJS | HttpClient

**DevOps**: Docker | PostgreSQL 12+ | Git

---

## 🚀 Quick Start (30 seconds)

### Using Docker (Recommended)

```bash
# One command to start everything
docker-compose up -d

# Access the application
Frontend: http://localhost:4200
Backend:  http://localhost:8080
Database: localhost:5432

# Login with
Username: admin
Password: admin123
```

### Manual Setup

See detailed instructions in [SETUP.md](docs/SETUP.md)

---

## 📖 Setup Guide

### Database
```bash
createdb auth_system
psql -U postgres -d auth_system < database/init.sql
psql -U postgres -d auth_system < database/seed-data.sql
```

### Backend
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

### Frontend
```bash
cd frontend
npm install
ng serve --open
```

For complete setup with troubleshooting, see [docs/SETUP.md](docs/SETUP.md)

---

## 🔌 API Endpoints

### Public Endpoints
```
POST   /api/auth/login              Login with credentials
POST   /api/auth/refresh            Refresh expired token
POST   /api/auth/logout             Logout user
```

### Admin Endpoints (Requires ADMIN role)
```
GET    /api/admin/users             List all users
POST   /api/admin/users             Create new user
DELETE /api/admin/users/{id}        Delete user
```

### Example Request
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'
```

---

## 🏗️ Architecture

```
┌────────────────────────────────┐
│     Angular Frontend           │
│   (Guards, Interceptors)       │
└──────────────┬─────────────────┘
               │ HTTP + JWT
               ▼
┌────────────────────────────────┐
│    Spring Boot Backend         │
│ (Security, JWT, Controllers)   │
└──────────────┬─────────────────┘
               │ SQL
               ▼
┌────────────────────────────────┐
│   PostgreSQL Database          │
│  (Users, Roles, Permissions)   │
└────────────────────────────────┘
```

### Authentication Flow

```
1. User submits credentials
   ↓
2. Backend validates password
   ↓
3. Backend creates JWT tokens
   ↓
4. Frontend stores tokens
   ↓
5. Frontend includes token in requests
   ↓
6. Backend validates token signature
   ↓
7. Backend checks user role
   ↓
8. Grant/deny access
```

---

## 🔐 Security Features

### Token Management
- **Access Token**: 15 minutes (short-lived for security)
- **Refresh Token**: 7 days (long-lived for convenience)
- **Signature**: HMAC SHA-256 with secret key
- **Validation**: Every request checked for validity

### Password Security
- **Hashing**: BCrypt with salt
- **Never Plain Text**: Passwords hashed before storage
- **Verified**: On every login attempt

### Session Management
- **Timeout**: 30 minutes of inactivity
- **Stateless**: No server-side session storage
- **JWT Based**: Tokens contain all necessary info

---

## 📁 Project Structure

```
enterprise-auth-system/
├── backend/                        # Spring Boot
│   ├── pom.xml                    # Dependencies
│   └── src/main/java/com/authsystem/
│       ├── AuthSystemApplication.java
│       ├── config/SecurityConfig.java
│       ├── controller/AuthController.java
│       ├── service/JwtService.java
│       ├── filter/JwtAuthenticationFilter.java
│       └── dto/LoginRequest.java, LoginResponse.java
│
├── frontend/                       # Angular
│   ├── package.json
│   └── src/app/shared/
│       ├── services/auth.service.ts
│       ├── guards/auth.guard.ts
│       └── interceptors/auth.interceptor.ts
│
├── database/                       # SQL Scripts
│   ├── init.sql                   # Create tables
│   └── seed-data.sql              # Initial data
│
├── docs/                           # Documentation
│   ├── SETUP.md                   # Setup instructions
│   ├── INTERVIEW_GUIDE.md         # Q&A for interviews
│   └── COMPLETE_IMPLEMENTATION.md  # Full code details
│
├── docker-compose.yml
├── README.md
└── .gitignore
```

---

## 👥 Test Accounts

| Username | Password | Role |
|----------|----------|------|
| admin | admin123 | ADMIN |
| user | user123 | USER |

---

## 📚 Documentation

### Learn How It Works
- **[INTERVIEW_GUIDE.md](docs/INTERVIEW_GUIDE.md)** - Complete explanations for interviews
  - Authentication vs Authorization
  - JWT token structure
  - Login flow step-by-step
  - Spring Security filter chain
  - Angular guards and interceptors
  - Database schema design
  - Common interview questions

### Setup & Deployment
- **[SETUP.md](docs/SETUP.md)** - Detailed setup instructions
  - Docker setup (recommended)
  - Manual setup
  - Environment configuration
  - Troubleshooting

### Code Details
- **[COMPLETE_IMPLEMENTATION.md](docs/COMPLETE_IMPLEMENTATION.md)** - Full source code walkthrough

---

## 🎓 Learning Outcomes

This project teaches:

✅ Full-stack development (Frontend + Backend + Database)  
✅ Enterprise authentication patterns  
✅ JWT token mechanics  
✅ Spring Security configuration  
✅ Angular security best practices  
✅ Database design with normalization  
✅ RESTful API design  
✅ Docker containerization  

---

## 🧪 Testing

### Quick Test with cURL

```bash
# 1. Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# 2. Use returned token
curl -X GET http://localhost:8080/api/admin/users \
  -H "Authorization: Bearer {accessToken}"

# 3. Test with invalid token (should get 401)
curl -X GET http://localhost:8080/api/admin/users \
  -H "Authorization: Bearer invalid_token"
```

### Browser Testing

1. Open http://localhost:4200
2. Login with admin/admin123
3. Observe auth guards protecting routes
4. Verify token sent in requests
5. Test logout functionality

---

## 🚀 What's Next?

Ready to expand this project? Consider:

1. **Add Unit Tests** - JUnit 5 for backend
2. **Add Integration Tests** - Testcontainers
3. **Email Verification** - Confirm user emails
4. **Password Reset** - Secure recovery flow
5. **Rate Limiting** - Prevent brute force
6. **OAuth2 Integration** - Google/GitHub login
7. **Audit Logging** - Track user actions
8. **Cloud Deployment** - AWS/Azure/Heroku

---

## 💡 Key Concepts

### Authentication
The process of verifying user identity through credentials (username/password).

### Authorization
The process of verifying what authenticated users are allowed to do (roles/permissions).

### JWT Token
A digitally signed token containing claims. Format: `Header.Payload.Signature`

### RBAC
Role-Based Access Control - users are assigned roles, roles have permissions.

---

## 📊 Project Statistics

| Metric | Value |
|--------|-------|
| Backend Files | 8 Java files |
| Frontend Files | 3 TypeScript files |
| Database Tables | 4 tables |
| API Endpoints | 6+ endpoints |
| Test Accounts | 2 accounts |
| Documentation | 3 guides |
| Lines of Code | 1500+ |

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

**Built with ❤️ for learning and career growth**

For the latest updates: [GitHub Repository](https://github.com/NMSP19/enterprise-auth-system)

---

**Last Updated**: March 2026 | Status: Production Ready ✅
