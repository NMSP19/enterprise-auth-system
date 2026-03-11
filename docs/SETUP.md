# 🚀 SETUP GUIDE - Run Everything Locally

## Quick Start (5 minutes with Docker)

### Option 1: Docker Compose (Recommended - All-in-One)

```bash
# 1. Navigate to project
cd enterprise-auth-system

# 2. Start everything
docker-compose up -d

# 3. Wait 30 seconds for services to start

# 4. Access
- Frontend: http://localhost:4200
- Backend: http://localhost:8080
- Database: localhost:5432

# 5. Login
- Username: admin, Password: admin123
- Or: username: user, Password: user123
```

### Option 2: Manual Setup (15 minutes)

#### Prerequisites
```bash
# Check Java
java -version  # Should be 17+

# Check Node
node -v  # Should be 18+

# Check npm
npm -v  # Should be 9+

# Check PostgreSQL
psql --version  # Should be 12+

# Check Maven
mvn -version  # Should be 3.8+
```

---

## Step 1: Database Setup

```bash
# 1. Create database
createdb auth_system

# 2. Create user (optional)
psql -U postgres
CREATE USER authuser WITH PASSWORD 'authpass123';
ALTER ROLE authuser CREATEDB;
GRANT ALL PRIVILEGES ON DATABASE auth_system TO authuser;
\q

# 3. Run migrations
psql -U postgres -d auth_system < database/init.sql
psql -U postgres -d auth_system < database/seed-data.sql

# 4. Verify tables created
psql -U postgres -d auth_system -c "\dt"
# Should show: users, roles, user_roles, permissions, role_permissions
```

---

## Step 2: Backend Setup & Run

```bash
# 1. Navigate to backend
cd backend

# 2. Create application.properties
cat > src/main/resources/application-local.properties << 'EOF'
spring.datasource.url=jdbc:postgresql://localhost:5432/auth_system
spring.datasource.username=postgres
spring.datasource.password=password
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false
spring.web.cors.allowed-origins=http://localhost:4200
server.port=8080
jwt.secret=this-is-a-very-long-secret-key-that-should-be-at-least-256-bits-long
jwt.expiration=900000
jwt.refresh-expiration=604800000
logging.level.com.authsystem=DEBUG
EOF

# 3. Build project
mvn clean install

# 4. Run application
mvn spring-boot:run

# 5. Verify startup
# Should see: "Started AuthSystemApplication"
# Should see: "Netty started on port(s): 8080"

# 6. Test backend
curl http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Should get JWT token
```

---

## Step 3: Frontend Setup & Run

```bash
# 1. Navigate to frontend
cd frontend

# 2. Install dependencies
npm install

# 3. Create environment config
cat > src/environments/environment.ts << 'EOF'
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api'
};
EOF

# 4. Start development server
ng serve

# 5. Verify in another terminal
curl http://localhost:4200

# 6. Open in browser
# http://localhost:4200
```

---

## Step 4: Test Everything

### Login Test
```bash
# 1. Go to http://localhost:4200
# 2. Login with:
#    Username: admin
#    Password: admin123
# 3. Should redirect to /admin
# 4. Should see user list
```

### API Test (with cURL)

```bash
# 1. Login and get token
TOKEN=$(curl -s http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' \
  | jq -r '.accessToken')

echo "Access Token: $TOKEN"

# 2. Use token in requests
curl http://localhost:8080/api/admin/users \
  -H "Authorization: Bearer $TOKEN"

# Should return list of users
```

---

## Troubleshooting

### PostgreSQL Connection Error
```bash
# Check if PostgreSQL is running
psql -U postgres -d postgres

# If error: "could not connect to server"
# Start PostgreSQL (MacOS):
brew services start postgresql

# Start PostgreSQL (Linux):
sudo systemctl start postgresql

# Start PostgreSQL (Windows):
# Open Services, find PostgreSQL, click Start
```

### Port Already in Use
```bash
# Port 8080 (Backend):
lsof -i :8080  # Find process
kill -9 <PID>  # Kill it

# Port 4200 (Frontend):
lsof -i :4200
kill -9 <PID>

# Or change port in application.properties or ng serve --port 4300
```

### Module Not Found
```bash
# Frontend:
rm -rf node_modules
npm install

# Backend:
mvn clean install
```

### Database Already Exists
```bash
# Drop and recreate
dropdb auth_system
createdb auth_system
psql -U postgres -d auth_system < database/init.sql
psql -U postgres -d auth_system < database/seed-data.sql
```

### JWT Secret Error
```bash
# Make sure environment variable is set
export JWT_SECRET="your-super-long-secret-key-that-is-at-least-256-bits"

# Or update application.properties directly
jwt.secret=your-super-long-secret-key-that-is-at-least-256-bits
```

---

## Project Structure After Setup

```
enterprise-auth-system/
├── backend/                          # Spring Boot Application
│   ├── src/main/java/com/authsystem/
│   │   ├── AuthSystemApplication.java
│   │   ├── config/
│   │   ├── controller/
│   │   ├── service/
│   │   ├── repository/
│   │   ├── entity/
│   │   ├── filter/
│   │   └── exception/
│   ├── src/main/resources/
│   │   ├── application.properties
│   │   ├── application-local.properties
│   │   └── db/migration/
│   └── pom.xml
├── frontend/                         # Angular Application
│   ├── src/
│   │   ├── app/
│   │   │   ├── modules/
│   │   │   │   ├── auth/
│   │   │   │   ├── admin/
│   │   │   │   └── user/
│   │   │   └── shared/
│   │   ├── environments/
│   │   └── assets/
│   ├── package.json
│   └── angular.json
├── database/
│   ├── init.sql
│   ├── seed-data.sql
│   └── entra-id-setup.md
├── docs/
│   ├── ARCHITECTURE.md
│   ├── SETUP.md
│   ├── API_DOCS.md
│   ├── INTERVIEW_GUIDE.md
│   └── COMPLETE_IMPLEMENTATION.md
├── docker-compose.yml
├── README.md
└── .gitignore
```

---

## Environment Variables

### Backend (Spring Boot)
```bash
# Database
DB_USERNAME=postgres
DB_PASSWORD=password
DATABASE_URL=jdbc:postgresql://localhost:5432/auth_system

# JWT
JWT_SECRET=this-is-a-very-long-secret-key-that-should-be-at-least-256-bits-long
JWT_EXPIRATION=900000
JWT_REFRESH_EXPIRATION=604800000

# Server
SERVER_PORT=8080

# Logging
LOG_LEVEL=DEBUG
```

### Frontend (Angular)
```bash
# API
API_URL=http://localhost:8080/api

# Environment
ENVIRONMENT=development
```

---

## Common Commands

### Maven Commands (Backend)
```bash
# Clean and build
mvn clean install

# Run tests
mvn test

# Run application
mvn spring-boot:run

# Skip tests during build
mvn clean install -DskipTests

# Show dependency tree
mvn dependency:tree

# Update dependencies
mvn versions:display-dependency-updates
```

### NPM Commands (Frontend)
```bash
# Install dependencies
npm install

# Start development server
ng serve

# Build for production
ng build --prod

# Run tests
ng test

# Run e2e tests
ng e2e

# Build and serve
ng serve --open  # Opens in browser automatically
```

### PostgreSQL Commands
```bash
# Connect to database
psql -U postgres -d auth_system

# List databases
\l

# List tables
\dt

# Show table structure
\d users

# Execute SQL file
psql -U postgres -d auth_system < file.sql

# Backup database
pg_dump -U postgres auth_system > backup.sql

# Restore database
psql -U postgres -d auth_system < backup.sql
```

---

## Database Reset

If something goes wrong, completely reset:

```bash
# 1. Drop database
dropdb auth_system

# 2. Create fresh database
createdb auth_system

# 3. Run fresh migrations
psql -U postgres -d auth_system < database/init.sql
psql -U postgres -d auth_system < database/seed-data.sql

# 4. Restart backend
# Ctrl+C to stop current run
mvn spring-boot:run
```

---

## Verify Setup

### Checklist
- [ ] PostgreSQL running (`psql -U postgres` works)
- [ ] Database created (`\l` shows auth_system)
- [ ] Tables created (`\dt` in auth_system shows 5 tables)
- [ ] Backend starts (`mvn spring-boot:run` succeeds)
- [ ] Backend accessible (`curl http://localhost:8080/actuator/health`)
- [ ] Frontend builds (`ng serve` starts without errors)
- [ ] Frontend accessible (`http://localhost:4200` loads)
- [ ] Login works (admin/admin123 redirects to /admin)
- [ ] JWT token generated (check browser dev tools → Application → localStorage → `accessToken`)

---

## Performance Tips

### Backend
- Use `spring.jpa.show-sql=false` in production
- Use `spring.jpa.properties.hibernate.format_sql=false` in production
- Enable query caching for frequently accessed data
- Use database connection pooling (HikariCP)

### Frontend
- Use production build: `ng build --prod --aot`
- Enable gzip compression in server
- Lazy load modules
- Implement virtual scrolling for large lists

### Database
- Add indexes on frequently queried columns
- Archive old login records periodically
- Backup regularly: `pg_dump`

---

## Next Steps

1. ✅ **Setup locally** - Follow this guide
2. **Understand code** - Read INTERVIEW_GUIDE.md
3. **Modify** - Add features, change design
4. **Test** - Write unit tests
5. **Deploy** - See DEPLOYMENT.md

---

## Getting Help

### Common Issues & Solutions

**"Port 8080 already in use"**
```bash
# Find and kill process using port
lsof -i :8080 | grep LISTEN
kill -9 <PID>
```

**"PostgreSQL password authentication failed"**
```bash
# Check PostgreSQL user
psql -U postgres

# If password wrong, reset:
sudo -u postgres psql
ALTER USER postgres WITH PASSWORD 'new_password';
\q
```

**"Cannot find module" (Frontend)**
```bash
rm -rf node_modules
npm cache clean --force
npm install
```

**"JWT parsing failed"**
```bash
# Make sure JWT secret is exactly the same in config
# And is at least 256 bits (32 characters) long
```

---

**Ready to start? Follow the Docker option for fastest setup!** 🚀

Questions? Check INTERVIEW_GUIDE.md or COMPLETE_IMPLEMENTATION.md
