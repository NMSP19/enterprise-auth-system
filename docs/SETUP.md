# 🚀 SETUP GUIDE - Run Enterprise Auth System

## Quick Start (Docker)

```bash
# One command to start everything
docker-compose up -d

# Visit:
# Frontend: http://localhost:4200
# Backend: http://localhost:8080
# Database: localhost:5432

# Login:
# Username: admin
# Password: admin123
```

---

## Manual Setup (15 minutes)

### Step 1: Database Setup

```bash
# Create database
createdb auth_system

# Run migrations
psql -U postgres -d auth_system < database/init.sql
psql -U postgres -d auth_system < database/seed-data.sql
```

### Step 2: Backend Setup

```bash
cd backend

# Build
mvn clean install

# Run
mvn spring-boot:run
```

Backend will start on: **http://localhost:8080**

### Step 3: Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Start development server
ng serve --open
```

Frontend will start on: **http://localhost:4200**

---

## Test Accounts

| Username | Password | Role |
|----------|----------|------|
| admin | admin123 | ADMIN |
| user | user123 | USER |

---

## API Endpoints

### Public
- POST /api/auth/login
- POST /api/auth/refresh
- POST /api/auth/logout

### Admin Only
- GET /api/admin/users
- POST /api/admin/users
- DELETE /api/admin/users/{id}

---

Ready? Start with: `docker-compose up -d` 🚀
