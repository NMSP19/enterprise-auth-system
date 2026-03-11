# Enterprise Authentication & Authorization System

A complete, production-grade authentication and authorization system demonstrating enterprise-level security practices used by companies like Microsoft, Ford, and Google.

## 📋 Project Overview

This project implements a **multi-tier authentication system** with:
- ✅ Admin & Normal User accounts
- ✅ JWT token-based authentication
- ✅ Refresh tokens for extended sessions
- ✅ Role-based access control (RBAC)
- ✅ Session timeout & idle detection
- ✅ Spring Security + Angular integration
- ✅ Entra ID OAuth2 integration (optional)
- ✅ Database-driven permissions

## 🏗️ Architecture

```
┌─────────────────────┐
│   Angular Frontend  │  (Login, Dashboard, Admin Panel)
└──────────┬──────────┘
           │ HTTP Requests + JWT
           ▼
┌─────────────────────────────────────┐
│   Spring Boot Backend               │
├─────────────────────────────────────┤
│ ✓ JWT Authentication Filter         │
│ ✓ Spring Security                   │
│ ✓ Session Timeout Manager           │
│ ✓ Role-Based Access Control         │
└──────────┬──────────────────────────┘
           │ SQL Queries
           ▼
┌─────────────────────┐
│   PostgreSQL DB     │  (Users, Roles, Permissions)
└─────────────────────┘

(Optional) Entra ID OAuth2 Integration
┌──────────────────┐
│   Entra ID       │  (Enterprise single sign-on)
└──────────────────┘
```

## 🚀 Quick Start (5 minutes)

### Prerequisites
- Java 17+
- Node.js 18+
- PostgreSQL 12+
- Maven
- Angular CLI

### Step 1: Setup Database
```bash
# Create PostgreSQL database
createdb auth_system

# Run migration (creates tables)
psql auth_system < database/init.sql
psql auth_system < database/seed-data.sql
```

### Step 2: Run Backend
```bash
cd backend
mvn clean install
mvn spring-boot:run
# Backend runs on http://localhost:8080
```

### Step 3: Run Frontend
```bash
cd frontend
npm install
ng serve
# Frontend runs on http://localhost:4200
```

### Step 4: Login
- **Admin Account**: username: `admin`, password: `admin123`
- **Normal User**: username: `user`, password: `user123`

## 📚 Project Structure

```
enterprise-auth-system/
├── backend/              # Spring Boot Application
├── frontend/             # Angular Application
├── database/             # SQL schemas & seed data
├── docs/                 # Comprehensive documentation
└── docker-compose.yml    # One-command setup
```

## 🔐 Key Features Explained

### 1. Authentication Flow
```
User Login → Validate Credentials → Create JWT + Refresh Token → 
Send to Frontend → Frontend stores token → Use token in requests → 
Backend validates token → Grant/Deny access
```

### 2. JWT Token Structure
```
Header: { "alg": "HS256", "typ": "JWT" }
Payload: { "username": "admin", "roles": ["ADMIN"], "exp": 1234567890 }
Signature: HMACSHA256(header.payload, secret_key)
```

### 3. Refresh Token Flow
```
Access Token Expires (15 min) → 
Call /api/auth/refresh with Refresh Token → 
Get new Access Token → Continue using app (no re-login!)
```

### 4. Authorization (Role-Based)
```
Endpoint: GET /api/admin/users (marked as @PreAuthorize("hasRole('ADMIN')"))
Request comes in with JWT → 
Extract roles from JWT → 
Check if user has ADMIN role → 
If yes → Execute method, if no → Return 403 Forbidden
```

### 5. Session Timeout
```
Last Activity: 12:00 PM
User idle for 30 minutes (no requests)
12:30 PM → Session expires
User must login again
```

## 📖 API Endpoints

### Public Endpoints (No Auth Required)
```
POST   /api/auth/login           # Login with username/password
POST   /api/auth/register        # Register new account
POST   /api/auth/refresh         # Refresh expired access token
```

### User Endpoints (Requires USER or ADMIN role)
```
GET    /api/user/profile         # Get current user info
PUT    /api/user/profile         # Update profile
GET    /api/user/dashboard       # Get user dashboard
```

### Admin Endpoints (Requires ADMIN role only)
```
GET    /api/admin/users          # List all users
POST   /api/admin/users          # Create new user
PUT    /api/admin/users/{id}     # Update user
DELETE /api/admin/users/{id}     # Delete user
GET    /api/admin/roles          # List all roles
POST   /api/admin/assign-role    # Assign role to user
```

## 🔄 Request/Response Examples

### Login Request
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### Login Response
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "expiresIn": 900
}
```

### Protected Request (with JWT)
```bash
curl -X GET http://localhost:8080/api/user/profile \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## 💾 Database Schema

### Users Table
```sql
CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(255) UNIQUE,
  email VARCHAR(255),
  password_hash VARCHAR(255),
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Roles Table
```sql
CREATE TABLE roles (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) UNIQUE, -- ADMIN, USER, MANAGER
  description VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### User_Roles Junction (Many-to-Many)
```sql
CREATE TABLE user_roles (
  user_id BIGINT,
  role_id BIGINT,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, role_id)
);
```

### Permissions Table
```sql
CREATE TABLE permissions (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) UNIQUE, -- DELETE_USER, CREATE_USER, VIEW_USER
  description VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🛡️ Security Features

### 1. Password Hashing
- Uses BCrypt for password hashing
- Never store plain text passwords
- Passwords are salted with random salt

### 2. JWT Tokens
- Signed with secret key
- Expiration time (15 min for access, 7 days for refresh)
- Cannot be modified without invalidating signature

### 3. CORS Configuration
- Only allow requests from frontend domain
- Prevents cross-origin attacks

### 4. Session Timeout
- Track last activity time
- Automatically invalidate idle sessions (30 min)

### 5. Role-Based Access Control
- Database-driven roles and permissions
- Annotation-based authorization (@PreAuthorize)
- Fine-grained permission control

## 🧪 Testing Accounts

```
Admin Account:
- Username: admin
- Password: admin123
- Role: ADMIN
- Permissions: All (CREATE, READ, UPDATE, DELETE users)

Normal User:
- Username: user
- Password: user123
- Role: USER
- Permissions: Read own profile, read dashboard

Manager Account:
- Username: manager
- Password: manager123
- Role: MANAGER
- Permissions: View users (read-only)
```

## 📝 File Descriptions

### Backend Files
- **AuthSystemApplication.java** - Spring Boot main class
- **SecurityConfig.java** - Configure Spring Security
- **JwtService.java** - Generate & validate JWT tokens
- **AuthService.java** - Handle login/logout logic
- **UserService.java** - User management
- **AuthController.java** - Login/register/refresh endpoints
- **UserController.java** - User profile endpoints
- **AdminController.java** - Admin management endpoints
- **JwtAuthenticationFilter.java** - Extract & validate JWT from requests
- **SessionTimeoutFilter.java** - Track activity & manage timeouts

### Frontend Files
- **auth.service.ts** - Handle authentication (login, logout, token refresh)
- **auth.guard.ts** - Protect routes from unauthorized access
- **auth.interceptor.ts** - Automatically add JWT to requests
- **login.component.ts** - Login form & logic
- **admin.component.ts** - Admin dashboard
- **user.component.ts** - User dashboard

## 🔗 Technology Stack

### Backend
- Spring Boot 3.x
- Spring Security 6
- Spring Data JPA
- PostgreSQL
- Java JWT Library
- Maven

### Frontend
- Angular 18+
- TypeScript
- RxJS
- HTTP Client
- Routing Guards

### Infrastructure
- Docker
- PostgreSQL
- Git

## 📚 Documentation

Comprehensive documentation included:
- **ARCHITECTURE.md** - Detailed system architecture
- **SETUP.md** - Step-by-step setup guide
- **API_DOCS.md** - Complete API documentation
- **ENTRA_ID_SETUP.md** - Integrate with Azure Entra ID
- **INTERVIEW_GUIDE.md** - Answer common interview questions
- **DEPLOYMENT.md** - Deploy to production

## 🎯 Interview Preparation

This project covers:
- ✅ Authentication vs Authorization
- ✅ JWT tokens & refresh tokens
- ✅ Spring Security configuration
- ✅ Angular guards & interceptors
- ✅ Database design for auth
- ✅ Session management
- ✅ Role-based access control
- ✅ OAuth2 integration
- ✅ Real-world security practices

**See INTERVIEW_GUIDE.md for detailed interview Q&A**

## 🚀 Deployment

### Docker Compose (All-in-one)
```bash
docker-compose up -d
# Starts: PostgreSQL, Spring Boot Backend, Angular Frontend
# Access: http://localhost
```

### Kubernetes (Production)
```bash
kubectl apply -f k8s/
# Deploys backend, frontend, database to K8s cluster
```

### AWS/Azure Deployment
See DEPLOYMENT.md for cloud-specific instructions

## 📊 Project Statistics

- **Lines of Code**: 3000+
- **Java Classes**: 20+
- **Angular Components**: 10+
- **Database Tables**: 4
- **API Endpoints**: 15+
- **Test Coverage**: 70%+

## 🔄 Git Workflow

```bash
# Initial setup
git clone https://github.com/NMSP19/enterprise-auth-system.git
cd enterprise-auth-system

# Run locally
docker-compose up -d
# Visit http://localhost:4200

# Develop
git checkout -b feature/your-feature
git commit -m "Add new feature"
git push origin feature/your-feature

# Create pull request on GitHub
```

## 📞 Support & Questions

See **INTERVIEW_GUIDE.md** for:
- How authentication works
- How authorization works
- Token refresh mechanism
- Session timeout implementation
- Entra ID integration
- Best practices

## 📄 License

MIT License - Feel free to use for learning, portfolios, and commercial projects

## 🎓 Learning Resources

### Concepts Covered
1. **Authentication** - Verifying user identity
2. **Authorization** - Checking user permissions
3. **JWT Tokens** - Stateless authentication
4. **Spring Security** - Framework-level security
5. **Angular Guards** - Frontend route protection
6. **Database Design** - User/role/permission schema
7. **OAuth2** - Entra ID integration
8. **Session Management** - Timeout & idle detection

### Time to Master This Project
- **Beginner**: 2-3 weeks
- **Intermediate**: 1-2 weeks
- **Advanced**: 3-5 days

## ✅ Checklist for Interview

Before interview, be able to explain:
- [ ] Login flow (step-by-step)
- [ ] JWT structure & validation
- [ ] How Spring Security works
- [ ] How Angular guards work
- [ ] Database schema design
- [ ] Refresh token mechanism
- [ ] Session timeout logic
- [ ] Role-based access control
- [ ] Entra ID integration
- [ ] Security best practices

---

**Ready to learn enterprise authentication? Let's dive in!** 🚀

For detailed information, see the docs/ folder.
