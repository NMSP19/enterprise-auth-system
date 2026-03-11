# 🎯 INTERVIEW GUIDE - Enterprise Authentication System

This guide answers all common interview questions about this project. Study this before interviews!

---

## SECTION 1: HIGH-LEVEL QUESTIONS

### Q1: "Tell me about this project in 2 minutes"

**Answer**:
"This is an enterprise-grade authentication and authorization system that demonstrates how companies like Microsoft, Ford, and Google handle user security.

The system has three main layers:

**1. Frontend (Angular)**: Users login through a form. After successful login, they receive a JWT token. This token is stored and included in every request to the backend. Angular has guards that prevent users from accessing admin pages if they're not admins.

**2. Backend (Spring Boot)**: When a request comes in with a JWT token, Spring Security validates it. It checks the token signature, expiration, and extracts the user's roles. Then it checks if the user has permission to access that endpoint. For example, if user tries to access /api/admin/users but they're not an admin, it returns 403 Forbidden.

**3. Database (PostgreSQL)**: Stores users, roles, and permissions in separate tables. When a user logs in, we query their roles and permissions from the database. Roles like ADMIN have permissions like DELETE_USER, CREATE_USER.

Key features:
- JWT tokens expire in 15 minutes (security)
- Refresh tokens expire in 7 days (convenience)
- Sessions timeout after 30 minutes of inactivity
- Passwords are hashed with BCrypt
- Two types of users: Admin (full access) and Normal User (limited access)

This is how real enterprise systems work."

---

### Q2: "Why is this project impressive for your resume?"

**Answer**:
"This project covers the full authentication & authorization stack:

1. **Backend Security** - Spring Security, JWT, password hashing
2. **Frontend Security** - Guards, interceptors, token management
3. **Database Design** - Normalized schema with relationships
4. **Enterprise Patterns** - RBAC, OAuth2 ready, session management
5. **Real-world** - This is how Ford, Microsoft, and Google do authentication

Most projects don't implement this completely. Most stop at basic login. This shows I understand enterprise security patterns, which is critical for senior roles.

It also demonstrates I can work with:
- Spring Boot backend
- Angular frontend
- PostgreSQL database
- JWT tokens
- Role-based access control
- OAuth2 (via Entra ID optional)

Combined, this is 60+ hours of work, showing deep technical knowledge."

---

## SECTION 2: AUTHENTICATION QUESTIONS

### Q3: "Walk me through the login process step-by-step"

**Answer**:
"When a user logs in, here's exactly what happens:

**Step 1: User enters credentials**
User types username 'admin' and password 'admin123' in Angular login form.

**Step 2: Frontend sends to backend**
Angular sends POST request to /api/auth/login with JSON:
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Step 3: Backend validates credentials**
Spring Boot AuthService does:
1. Query database: SELECT * FROM users WHERE username='admin'
2. Check if user exists (if not, return 401 Unauthorized)
3. Hash the provided password with BCrypt
4. Compare hashed password with password_hash in database
5. If match → Continue, if not → Return 401 Unauthorized

**Step 4: Create tokens**
If password valid:
```java
String accessToken = jwtService.generateAccessToken(user); // 15 min expiry
String refreshToken = jwtService.generateRefreshToken(user); // 7 days expiry
```

Access token payload contains:
```json
{
  "username": "admin",
  "roles": ["ADMIN"],
  "iat": 1710000000,
  "exp": 1710000900
}
```

**Step 5: Send tokens to frontend**
Backend returns:
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "expiresIn": 900
}
```

**Step 6: Frontend stores tokens**
Angular stores in:
- accessToken → localStorage (can be accessed by JS)
- refreshToken → HTTP-only cookie (secure, can't be accessed by JS)

**Step 7: Redirect to dashboard**
Frontend redirects user to /dashboard
User sees their username in top right → Login successful!

**Step 8: Use token in requests**
When user clicks "View Users", Angular automatically:
1. Gets accessToken from localStorage
2. Adds to request header: Authorization: Bearer [accessToken]
3. Sends GET /api/admin/users with header

**Step 9: Backend validates token**
Spring Security Filter intercepts request:
1. Extract token from Authorization header
2. Verify signature (if tampered → reject)
3. Check expiration (if expired → return 401)
4. Extract username and roles from token
5. Load user details from database
6. Check if user has ADMIN role
7. If yes → Call controller, if no → Return 403 Forbidden

That's the complete flow!"

---

### Q4: "What is JWT? How does it work?"

**Answer**:
"JWT = JSON Web Token. It's a way to securely pass information between frontend and backend.

**Structure**:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9 . eyJzdWIiOiIxMjM0NTY3ODkwIn0 . SflKxwRJ...
     HEADER                                PAYLOAD                              SIGNATURE
```

**Header** (Base64 encoded):
```json
{
  "alg": "HS256",      // Signing algorithm
  "typ": "JWT"         // Type is JWT
}
```

**Payload** (Base64 encoded):
```json
{
  "username": "admin",
  "roles": ["ADMIN"],
  "iat": 1710000000,   // Issued at time
  "exp": 1710000900    // Expiration time
}
```

**Signature**:
```
HMACSHA256(base64(header) + "." + base64(payload), secret_key)
```
Uses the secret key stored on backend to sign. If anyone modifies the payload, signature becomes invalid.

**How it works**:
1. Backend creates JWT with user data
2. Signs it with secret key
3. Sends to frontend
4. Frontend includes JWT in every request
5. Backend receives JWT
6. Verifies signature using secret key
7. If signature valid → Trust the payload
8. If signature invalid → Someone tampered with token, reject it

**Why use JWT?**
- Stateless (no session storage needed)
- Works across servers (each server has same secret)
- Mobile-friendly (no cookies needed)
- Microservices-friendly (each service can validate independently)

**Example in code**:
```java
// Creating JWT
String token = Jwts.builder()
  .setSubject(user.getUsername())
  .claim("roles", user.getRoles())
  .setIssuedAt(new Date())
  .setExpiration(new Date(System.currentTimeMillis() + 900000)) // 15 min
  .signWith(SignatureAlgorithm.HS256, secretKey)
  .compact();

// Validating JWT
Claims claims = Jwts.parser()
  .setSigningKey(secretKey)
  .parseClaimsJws(token)
  .getBody();
String username = claims.getSubject();
```

The key insight: JWT is like a tamper-evident seal. If anyone changes it, the signature breaks."

---

## SECTION 3: AUTHORIZATION QUESTIONS

### Q5: "How does authorization work? What's the difference from authentication?"

**Answer**:
"**Authentication** = "Are you who you claim to be?"  
**Authorization** = "What are you allowed to do?"

Example:
- Authentication: Your passport confirms you're Sai (✓ you are who you claim)
- Authorization: The stamp in your passport says you can visit USA (✓ you're allowed)

**In our project**:

**Authentication** (Login):
```
User enters password → Backend verifies → Creates JWT → Proves user identity
```

**Authorization** (Access Control):
```
User tries to access /api/admin/users
GET /api/admin/users (with JWT token)
    ↓
@PreAuthorize("hasRole('ADMIN')")  // Check role
    ↓
User has ADMIN role? YES → Execute method → Return users
User has USER role?  NO  → Return 403 Forbidden
```

**How it's implemented**:

**Step 1: Store roles in database**
```sql
INSERT INTO roles VALUES (1, 'ADMIN', 'Administrator');
INSERT INTO roles VALUES (2, 'USER', 'Normal User');
INSERT INTO user_roles VALUES (1, 1); -- User 1 has ADMIN role
INSERT INTO user_roles VALUES (2, 2); -- User 2 has USER role
```

**Step 2: Load roles from token**
When JWT is validated:
```java
Claims claims = parseJWT(token);
String username = claims.getSubject();
List<String> roles = claims.get("roles"); // ["ADMIN"]
```

**Step 3: Check authorization on endpoint**
```java
@RestController
public class AdminController {
  
  @GetMapping("/admin/users")
  @PreAuthorize("hasRole('ADMIN')")  // Only ADMIN can access
  public List<User> getAllUsers() {
    return userService.getAllUsers();
  }
  
  @DeleteMapping("/admin/users/{id}")
  @PreAuthorize("hasRole('ADMIN')")  // Only ADMIN can delete
  public void deleteUser(@PathVariable Long id) {
    userService.deleteUser(id);
  }
  
  @GetMapping("/user/profile")
  @PreAuthorize("hasAnyRole('ADMIN', 'USER')")  // ADMIN or USER
  public User getProfile() {
    return userService.getCurrentUser();
  }
}
```

**When request comes in with JWT**:
1. Spring Security Filter extracts JWT
2. Validates signature & expiration
3. Extracts username and roles
4. Creates Authentication object with roles
5. Request tries to access /api/admin/users
6. Spring sees @PreAuthorize("hasRole('ADMIN')")
7. Checks if user has ADMIN role
8. If yes → Proceed, if no → Return 403 Forbidden

**Real example**:

User 'admin' (role: ADMIN) requests GET /api/admin/users → ✅ Allowed  
User 'user' (role: USER) requests GET /api/admin/users → ❌ 403 Forbidden  
User 'user' (role: USER) requests GET /user/profile → ✅ Allowed  

That's the difference!"

---

### Q6: "How do you manage permissions in the database?"

**Answer**:
"We use a 4-table approach:

**Table 1: Users** (Who are the users?)
```sql
CREATE TABLE users (
  id BIGINT PRIMARY KEY,
  username VARCHAR(255),
  email VARCHAR(255),
  password_hash VARCHAR(255),
  is_active BOOLEAN
);
```

**Table 2: Roles** (What are the roles?)
```sql
CREATE TABLE roles (
  id BIGINT PRIMARY KEY,
  name VARCHAR(255),      -- ADMIN, USER, MANAGER
  description VARCHAR(255)
);
```

**Table 3: User_Roles** (Which roles do users have?)
```sql
CREATE TABLE user_roles (
  user_id BIGINT,
  role_id BIGINT,
  PRIMARY KEY (user_id, role_id)
);
```

Example:
```sql
INSERT INTO user_roles VALUES (1, 1);  -- User 1 has role 1 (ADMIN)
INSERT INTO user_roles VALUES (2, 2);  -- User 2 has role 2 (USER)
INSERT INTO user_roles VALUES (3, 2);  -- User 3 has role 2 (USER)
```

**Table 4: Permissions** (What can roles do?)
```sql
CREATE TABLE permissions (
  id BIGINT PRIMARY KEY,
  name VARCHAR(255),      -- DELETE_USER, CREATE_USER, VIEW_USER
  description VARCHAR(255)
);

CREATE TABLE role_permissions (
  role_id BIGINT,
  permission_id BIGINT,
  PRIMARY KEY (role_id, permission_id)
);
```

Example:
```sql
-- ADMIN role can DELETE_USER
INSERT INTO role_permissions VALUES (1, 1);  -- Role ADMIN, Permission DELETE_USER
-- USER role cannot DELETE_USER
-- (No entry in role_permissions)
```

**Query: What can user 'admin' do?**
```sql
SELECT DISTINCT p.name
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN role_permissions rp ON ur.role_id = rp.role_id
JOIN permissions p ON rp.permission_id = p.id
WHERE u.username = 'admin';

-- Result:
-- DELETE_USER
-- CREATE_USER
-- UPDATE_USER
-- READ_USER
```

**In Spring Boot**:
```java
@Entity
public class User {
  @ManyToMany
  private Set<Role> roles;
}

@Entity
public class Role {
  @ManyToMany
  private Set<Permission> permissions;
}

// Load user with all roles and permissions
User user = userRepository.findByUsername("admin");
Set<Role> roles = user.getRoles();       // [ADMIN]
Set<Permission> permissions = roles.stream()
  .flatMap(r -> r.getPermissions().stream())
  .collect(toSet());                      // [DELETE_USER, CREATE_USER...]
```

**Fine-grained authorization**:
```java
@PreAuthorize("hasPermission(#user, 'DELETE')")
public void deleteUser(@PathVariable User user) {
  // Only execute if user has DELETE permission
}
```

This allows easy permission management:
- Add new role → Insert in roles table
- Assign to user → Insert in user_roles
- Give role a permission → Insert in role_permissions

Much better than hardcoding permissions in code!"

---

## SECTION 4: REFRESH TOKEN QUESTIONS

### Q7: "Explain refresh tokens and why we need them"

**Answer**:
"**Problem**: JWT access tokens expire (15 min for security). But asking user to login every 15 min is terrible UX.

**Solution**: Use two tokens:
1. **Access Token** (15 min) - Actual requests
2. **Refresh Token** (7 days) - Get new access token

**How it works**:

**Step 1: Initial login**
```
User logs in → Backend creates:
  - accessToken (15 min expiry)
  - refreshToken (7 days expiry)
→ Sends both to frontend
```

**Step 2: Use access token**
```
Frontend: Make requests using accessToken
GET /api/user/profile (with accessToken)
Backend: Validates accessToken → OK, return data
```

**Step 3: Access token expires (15 min later)**
```
GET /api/user/profile (with expired accessToken)
Backend: 
  - Tries to validate accessToken
  - Sees it's expired
  - Returns 401 Unauthorized with message "Token expired"
```

**Step 4: Refresh the token**
```
Frontend (in HTTP interceptor):
  - See 401 response
  - Have another chance: Try to refresh
  - POST /api/auth/refresh (with refreshToken in cookie)
  
Backend:
  - Receives refreshToken
  - Validates refreshToken (still valid? expires in 7 days)
  - If valid → Create new accessToken
  - Return new accessToken
```

**Step 5: Retry original request**
```
Frontend (using new accessToken):
  - GET /api/user/profile (with NEW accessToken)
Backend: 
  - Validates new accessToken → OK
  - Return data
  
User doesn't notice! They keep using app without re-login!
```

**Code example** (Pseudocode):

Backend:
```java
@PostMapping("/auth/refresh")
public TokenResponse refresh(@CookieValue("refreshToken") String refreshToken) {
  // Validate refresh token
  if (!isTokenValid(refreshToken)) {
    return new TokenResponse(null, "Refresh token expired, please login");
  }
  
  // Extract user from refresh token
  String username = extractUsername(refreshToken);
  User user = userService.findByUsername(username);
  
  // Create NEW access token
  String newAccessToken = generateAccessToken(user);
  
  return new TokenResponse(newAccessToken, "Token refreshed");
}
```

Frontend (in HTTP interceptor):
```typescript
intercept(request, next) {
  return next.handle(request).pipe(
    catchError(error => {
      if (error.status === 401) {
        // Access token expired, try refresh
        return this.authService.refreshToken().pipe(
          switchMap(response => {
            // Got new access token
            let newRequest = request.clone({
              setHeaders: { Authorization: `Bearer ${response.accessToken}` }
            });
            return next.handle(newRequest); // Retry original request
          })
        );
      }
      return throwError(error);
    })
  );
}
```

**Why two tokens?**
- If accessToken stolen → Only 15 min damage (attacker can act for 15 min)
- Refresh token stored in HTTP-only cookie → Can't be stolen by JavaScript
- User can stay logged in for 7 days → Good UX
- Still secure → Only backend can create tokens

This is how Spotify, Netflix, Google do it!"

---

## SECTION 5: SESSION TIMEOUT QUESTIONS

### Q8: "How do you manage session timeout and idle detection?"

**Answer**:
"Session timeout means: If user is inactive for 30 minutes, automatically log them out.

**Implementation**:

**Step 1: Create session tracker**
```java
@Component
public class SessionTimeoutManager {
  
  private Map<String, LocalDateTime> lastActivityMap = new ConcurrentHashMap<>();
  
  public void recordActivity(String username) {
    lastActivityMap.put(username, LocalDateTime.now());
  }
  
  public boolean isSessionValid(String username) {
    LocalDateTime lastActivity = lastActivityMap.get(username);
    if (lastActivity == null) return false; // User not logged in
    
    // Check if inactive for > 30 minutes
    long minutesSinceActivity = ChronoUnit.MINUTES
      .between(lastActivity, LocalDateTime.now());
    
    if (minutesSinceActivity > 30) {
      return false; // Session expired due to inactivity
    }
    
    return true; // Session still valid
  }
  
  public void invalidateSession(String username) {
    lastActivityMap.remove(username);
  }
}
```

**Step 2: Create filter to track activity**
```java
@Component
public class SessionTimeoutFilter extends OncePerRequestFilter {
  
  @Autowired
  private SessionTimeoutManager sessionTimeoutManager;
  
  @Override
  protected void doFilterInternal(HttpServletRequest request, 
                                 HttpServletResponse response, 
                                 FilterChain filterChain) throws ServletException, IOException {
    
    // Get current username from JWT
    String username = SecurityContextHolder.getContext()
      .getAuthentication().getName();
    
    // Check if session is still valid (not idle > 30 min)
    if (!sessionTimeoutManager.isSessionValid(username)) {
      sessionTimeoutManager.invalidateSession(username);
      response.sendError(HttpServletResponse.SC_UNAUTHORIZED, 
                        "Session expired due to inactivity");
      return;
    }
    
    // Record this activity (update last activity time)
    sessionTimeoutManager.recordActivity(username);
    
    // Continue to next filter
    filterChain.doFilter(request, response);
  }
}
```

**Step 3: Register filter in Spring**
```java
@Configuration
public class SecurityConfig {
  
  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
      // Add our custom filter
      .addFilterBefore(new SessionTimeoutFilter(), UsernamePasswordAuthenticationFilter.class)
      .authorizeRequests()
      .antMatchers("/api/auth/login", "/api/auth/register").permitAll()
      .anyRequest().authenticated()
      .and()
      .sessionManagement()
      .sessionFixationProtection(SessionFixationProtection.MITIGATE)
      .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
      .and()
      .csrf().disable();
    
    return http.build();
  }
}
```

**How it works in practice**:

```
12:00 PM - User logs in
         - System: lastActivityMap["admin"] = 12:00 PM

12:05 PM - User clicks "View Profile"
         - System records activity: lastActivityMap["admin"] = 12:05 PM

12:30 PM - User is idle (no requests)
         - System doesn't update lastActivityMap

12:31 PM - User clicks "View Users"
         - System checks: Last activity was at 12:05 PM
         - Now is 12:31 PM → 26 minutes idle
         - Still < 30 min → OK
         - System records new activity: lastActivityMap["admin"] = 12:31 PM

12:35 PM - User is still idle

12:36 PM - User clicks "Refresh"
         - System checks: Last activity was at 12:31 PM
         - Now is 12:36 PM → 5 minutes idle
         - < 30 min → Still OK

1:05 PM  - User tries to click something
         - System checks: Last activity was at 12:31 PM
         - Now is 1:05 PM → 34 minutes idle
         - > 30 min → SESSION EXPIRED
         - System invalidates session
         - Returns 401 Unauthorized
         - Frontend redirects to login page
         - User must login again
```

**Frontend handling**:
```typescript
// In HTTP interceptor
intercept(request, next) {
  return next.handle(request).pipe(
    catchError(error => {
      if (error.status === 401 && 
          error.error.message === 'Session expired due to inactivity') {
        // Session timed out
        this.authService.logout();
        this.router.navigate(['/login']);
        this.notificationService.show('Session expired. Please login again.');
        return throwError('Session expired');
      }
      return throwError(error);
    })
  );
}
```

**Why this matters**:
- Security: Unattended computers get logged out
- Compliance: Many enterprises require session timeouts
- Resource management: Inactive sessions freed up
- User experience: Clear message about timeout

Other timeouts:
- **Token expiration** (15 min): Token itself expires
- **Refresh token expiration** (7 days): Must login again
- **Session timeout** (30 min idle): Active users not affected

Ford and Microsoft use this exactly!"

---

## SECTION 6: SPRING SECURITY QUESTIONS

### Q9: "Explain how Spring Security Filter Chain works"

**Answer**:
"Spring Security uses a **filter chain** to protect your application. Think of it as airport security with multiple checkpoints.

**Filter Chain** (in order):

```
Request comes in
  ↓
[1] SecurityContextPersistenceFilter
    - Loads existing security context
  ↓
[2] LogoutFilter  
    - Handles logout requests
  ↓
[3] UsernamePasswordAuthenticationFilter
    - Handles login form submissions
  ↓
[4] JwtAuthenticationFilter (OUR CUSTOM)
    - Extracts JWT from request headers
    - Validates JWT signature & expiration
    - Loads user authorities from JWT
    - Creates Authentication object
  ↓
[5] SessionTimeoutFilter (OUR CUSTOM)
    - Checks if session is still active (not idle > 30 min)
    - Records activity time
  ↓
[6] AuthorizationFilter
    - Checks if user has required roles/permissions
    - Matches against @PreAuthorize annotations
  ↓
[7] ExceptionTranslationFilter
    - Handles authentication/authorization exceptions
    - Redirects to login if not authenticated
    - Returns 403 if not authorized
  ↓
[8] FilterSecurityInterceptor
    - Final authorization check before controller
  ↓
Your Controller Code
  ↓
Response sent back through filter chain (reverse order)
```

**Example: User makes request**

```
1. User: GET /api/admin/users
   Header: Authorization: Bearer eyJhbGc...

2. SecurityContextPersistenceFilter:
   - Check if user already authenticated
   - If yes, load existing context

3. LogoutFilter:
   - Is this a logout request? No → Continue

4. UsernamePasswordAuthenticationFilter:
   - Is this a login form submission? No → Continue

5. JwtAuthenticationFilter:
   - Extract header: Authorization: Bearer eyJhbGc...
   - Remove "Bearer " prefix: eyJhbGc...
   - Validate JWT:
     * Verify signature using secret key
     * If invalid → Return 401 Unauthorized
     * If valid → Continue
   - Check expiration:
     * Parse claims: exp = 1710000900
     * Current time = 1710000500
     * Not expired → Continue
   - Extract user info from JWT:
     * username = "admin"
     * roles = ["ADMIN"]
   - Create Authentication object:
     * Authentication auth = new UsernamePasswordAuthenticationToken(
         "admin", // principal
         null,    // credentials
         [GrantedAuthority("ADMIN")]  // authorities
       );
   - Set in SecurityContext:
     * SecurityContextHolder.getContext().setAuthentication(auth);

6. SessionTimeoutFilter:
   - Get username: "admin"
   - Check last activity: 12:31 PM
   - Current time: 12:45 PM → 14 minutes
   - < 30 minutes → OK
   - Record new activity

7. AuthorizationFilter:
   - Check endpoint: /api/admin/users
   - Look for @PreAuthorize("hasRole('ADMIN')")
   - Get user authorities: [ADMIN]
   - Does user have ADMIN role? YES
   - Continue to controller

8. FilterSecurityInterceptor:
   - Final check
   - Allow request

9. Your Controller:
   @GetMapping("/admin/users")
   @PreAuthorize("hasRole('ADMIN')")
   public List<User> getAllUsers() {
     return userService.getAllUsers();
   }
   
   - This method executes
   - Returns list of users

10. Response goes back through filters (reverse)
    - ExceptionTranslationFilter: No exceptions
    - SessionTimeoutFilter: Update activity
    - JwtAuthenticationFilter: No action
    - LogoutFilter: No action
    - SecurityContextPersistenceFilter: Clean up context
    - Response sent to user with 200 OK + user list
```

**Custom Filter Implementation**:

```java
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
  
  @Autowired
  private JwtService jwtService;
  
  @Override
  protected void doFilterInternal(HttpServletRequest request, 
                                 HttpServletResponse response, 
                                 FilterChain filterChain) 
                     throws ServletException, IOException {
    
    try {
      // Extract JWT from header
      String authHeader = request.getHeader("Authorization");
      if (authHeader != null && authHeader.startsWith("Bearer ")) {
        String token = authHeader.substring(7); // Remove "Bearer "
        
        // Validate and parse JWT
        if (jwtService.isTokenValid(token)) {
          String username = jwtService.extractUsername(token);
          List<String> roles = jwtService.extractRoles(token);
          
          // Create authorities
          List<GrantedAuthority> authorities = roles.stream()
            .map(SimpleGrantedAuthority::new)
            .collect(toList());
          
          // Create Authentication object
          Authentication authentication = 
            new UsernamePasswordAuthenticationToken(
              username, 
              null, 
              authorities
            );
          
          // Set in SecurityContext
          SecurityContextHolder.getContext().setAuthentication(authentication);
        }
      }
      
      // Continue to next filter
      filterChain.doFilter(request, response);
      
    } catch (Exception e) {
      response.sendError(401, "Unauthorized: " + e.getMessage());
    }
  }
}
```

**Register in Spring**:

```java
@Configuration
public class SecurityConfig {
  
  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
      // Add our custom JWT filter BEFORE UsernamePasswordAuthenticationFilter
      .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class)
      
      // Add our custom session timeout filter
      .addFilterAfter(sessionTimeoutFilter(), JwtAuthenticationFilter.class)
      
      // Authorize requests
      .authorizeRequests()
      .antMatchers("/api/auth/login", "/api/auth/register").permitAll()
      .antMatchers("/api/admin/**").hasRole("ADMIN")
      .anyRequest().authenticated()
      
      // Disable session management (stateless JWT)
      .sessionManagement()
      .sessionCreationPolicy(SessionCreationPolicy.STATELESS);
    
    return http.build();
  }
  
  @Bean
  public JwtAuthenticationFilter jwtAuthenticationFilter() {
    return new JwtAuthenticationFilter();
  }
  
  @Bean
  public SessionTimeoutFilter sessionTimeoutFilter() {
    return new SessionTimeoutFilter();
  }
}
```

**Key points**:
- Filters are applied in order before controller
- Filters applied in reverse order after controller
- Each filter can reject request early (return error)
- If all filters pass → Controller executes
- This is how Spring prevents unauthorized access!"

---

## SECTION 7: ANGULAR INTEGRATION QUESTIONS

### Q10: "How do Angular Guards and Interceptors work?"

**Answer**:
"**Guards** = Prevent unauthorized access to routes  
**Interceptors** = Automatically add JWT to every request

**GUARDS** (Frontend Route Protection):

```typescript
@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {
  
  constructor(private authService: AuthService, private router: Router) {}
  
  canActivate(route: ActivatedRouteSnapshot): boolean {
    // Check 1: Is user logged in?
    if (!this.authService.isLoggedIn()) {
      // No → Redirect to login
      this.router.navigate(['/login']);
      return false;
    }
    
    // Check 2: Does route require specific role?
    const requiredRole = route.data['role'];
    if (requiredRole) {
      // Check if user has required role
      if (!this.authService.hasRole(requiredRole)) {
        // No → Redirect to 403
        this.router.navigate(['/unauthorized']);
        return false;
      }
    }
    
    // All checks passed → Allow access
    return true;
  }
}
```

**Register in routing**:
```typescript
const routes: Routes = [
  { path: 'login', component: LoginComponent },
  
  // Public route (no guard)
  { path: 'home', component: HomeComponent },
  
  // Protected route (requires login)
  { 
    path: 'user', 
    component: UserComponent,
    canActivate: [AuthGuard]
  },
  
  // Admin-only route (requires ADMIN role)
  { 
    path: 'admin', 
    component: AdminComponent,
    canActivate: [AuthGuard],
    data: { role: 'ADMIN' }
  },
  
  // Manager-only route
  { 
    path: 'manager', 
    component: ManagerComponent,
    canActivate: [AuthGuard],
    data: { role: 'MANAGER' }
  }
];
```

**How it works**:
```
User navigates to /admin
  ↓
Router: "Should I allow this?"
  ↓
AuthGuard.canActivate():
  - Is user logged in? (Check localStorage for token)
  - Does user have ADMIN role? (Decode JWT, check roles claim)
  - If yes → Return true → Route loads
  - If no → Return false → Route blocked, redirect to login
```

**INTERCEPTORS** (Automatic JWT Attachment):

```typescript
@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  
  constructor(private authService: AuthService) {}
  
  intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    // Get access token from localStorage
    const token = this.authService.getAccessToken();
    
    if (token) {
      // Clone request and add Authorization header
      request = request.clone({
        setHeaders: {
          Authorization: `Bearer ${token}`
        }
      });
    }
    
    // Send request to backend
    return next.handle(request).pipe(
      catchError((error: HttpErrorResponse) => {
        // Handle 401 (Unauthorized/Token Expired)
        if (error.status === 401) {
          return this.handleTokenExpired(request, next);
        }
        return throwError(error);
      })
    );
  }
  
  private handleTokenExpired(request: HttpRequest<any>, 
                            next: HttpHandler): Observable<HttpEvent<any>> {
    // Try to refresh token
    return this.authService.refreshToken().pipe(
      switchMap((response: TokenResponse) => {
        // Got new token
        const newToken = response.accessToken;
        
        // Retry original request with new token
        let retryRequest = request.clone({
          setHeaders: {
            Authorization: `Bearer ${newToken}`
          }
        });
        
        return next.handle(retryRequest);
      }),
      catchError(() => {
        // Refresh failed → Force logout
        this.authService.logout();
        this.router.navigate(['/login']);
        return throwError('Session expired');
      })
    );
  }
}
```

**Register in module**:
```typescript
@NgModule({
  imports: [HttpClientModule],
  providers: [
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true  // Can have multiple interceptors
    }
  ]
})
export class AppModule { }
```

**How it works**:
```
User makes HTTP request:
  GET /api/user/profile

AuthInterceptor.intercept():
  - Get token from localStorage: "eyJhbGc..."
  - Clone request and add header:
    Authorization: Bearer eyJhbGc...
  - Send modified request to backend
  
Backend receives:
  - Header: Authorization: Bearer eyJhbGc...
  - Validates JWT
  - Returns data

Response comes back:
  - If 200 OK → Interceptor returns to component
  - If 401 Unauthorized → 
    * Interceptor tries to refresh token
    * If refresh succeeds → Retry original request
    * If refresh fails → Logout user

Component receives response:
  - Component doesn't know about token refresh
  - Just sees successful response!
```

**Execution order**:
```
User clicks "Load Data"
    ↓
Component: this.http.get('/api/user/data')
    ↓
AuthInterceptor.intercept():
    [Adds Authorization header]
    ↓
HTTP Request sent to backend
    ↓
Backend validates JWT
    ↓
Response comes back
    ↓
AuthInterceptor catches response
    [Check for 401, refresh if needed]
    ↓
Component receives final response
    [No need to handle token refresh manually]
```

**Why this is great**:
- Token automatically added to every request
- No need to manually add Authorization header
- Automatic token refresh handling
- All HTTP requests go through same security flow
- DRY principle - token management in one place

This is exactly how Netflix, Spotify, Google apps work!"

---

## SECTION 8: DATABASE DESIGN QUESTIONS

### Q11: "Show me the database schema and explain relationships"

**Answer**:

**Schema Overview**:
```
users (1) ──────┐
                 │ many-to-many
          ┌──────── (1) roles
          │
    user_roles
          │
          └──────── (1) role_permissions
                           │
                           └──────── (1) permissions
```

**SQL Schema**:

```sql
-- Users Table
CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(255) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_username (username)
);

-- Roles Table (What are the roles?)
CREATE TABLE roles (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) UNIQUE NOT NULL,  -- ADMIN, USER, MANAGER
  description VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_name (name)
);

-- User_Roles Junction Table (Which users have which roles?)
-- Many-to-many relationship: One user can have many roles, one role can have many users
CREATE TABLE user_roles (
  user_id BIGINT NOT NULL,
  role_id BIGINT NOT NULL,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, role_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_role_id (role_id)
);

-- Permissions Table (What actions are available?)
CREATE TABLE permissions (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) UNIQUE NOT NULL,  -- DELETE_USER, CREATE_USER, etc.
  description VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_name (name)
);

-- Role_Permissions Junction Table (Which roles have which permissions?)
-- Many-to-many relationship: One role can have many permissions
CREATE TABLE role_permissions (
  role_id BIGINT NOT NULL,
  permission_id BIGINT NOT NULL,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (role_id, permission_id),
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
  FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
  INDEX idx_role_id (role_id),
  INDEX idx_permission_id (permission_id)
);
```

**Sample Data**:

```sql
-- Insert roles
INSERT INTO roles (name, description) VALUES 
  ('ADMIN', 'Administrator with full access'),
  ('USER', 'Regular user with limited access'),
  ('MANAGER', 'Manager with team management access');

-- Insert users
INSERT INTO users (username, email, password_hash, first_name, last_name) VALUES
  ('admin', 'admin@example.com', 'bcrypt_hash_1', 'Admin', 'User'),
  ('user', 'user@example.com', 'bcrypt_hash_2', 'Normal', 'User'),
  ('manager', 'manager@example.com', 'bcrypt_hash_3', 'Manager', 'User');

-- Assign roles to users
INSERT INTO user_roles (user_id, role_id) VALUES
  (1, 1),  -- User 'admin' has role 'ADMIN'
  (2, 2),  -- User 'user' has role 'USER'
  (3, 3);  -- User 'manager' has role 'MANAGER'

-- Insert permissions
INSERT INTO permissions (name, description) VALUES
  ('VIEW_USER', 'Can view user information'),
  ('CREATE_USER', 'Can create new users'),
  ('UPDATE_USER', 'Can update user information'),
  ('DELETE_USER', 'Can delete users'),
  ('MANAGE_ROLES', 'Can manage roles and permissions');

-- Assign permissions to roles
INSERT INTO role_permissions (role_id, permission_id) VALUES
  (1, 1), (1, 2), (1, 3), (1, 4), (1, 5),  -- ADMIN has all permissions
  (2, 1),                                    -- USER can only view
  (3, 1), (3, 2), (3, 3);                   -- MANAGER can view, create, update
```

**Queries to get user information**:

```sql
-- Get user with all their roles
SELECT u.id, u.username, r.name as role_name
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
WHERE u.username = 'admin';

-- Result:
-- id=1, username='admin', role_name='ADMIN'

-- Get all permissions for a user
SELECT DISTINCT p.name
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN role_permissions rp ON ur.role_id = rp.role_id
JOIN permissions p ON rp.permission_id = p.id
WHERE u.username = 'admin';

-- Result:
-- VIEW_USER
-- CREATE_USER
-- UPDATE_USER
-- DELETE_USER
-- MANAGE_ROLES

-- Get all users with a specific role
SELECT u.username, u.email
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
WHERE r.name = 'ADMIN';

-- Result:
-- username='admin', email='admin@example.com'
```

**JPA Entities** (Spring Boot):

```java
@Entity
@Table(name = "users")
public class User {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;
  
  @Column(unique = true, nullable = false)
  private String username;
  
  @Column(unique = true)
  private String email;
  
  @Column(nullable = false)
  private String passwordHash;
  
  private String firstName;
  private String lastName;
  private Boolean isActive;
  
  @ManyToMany(fetch = FetchType.EAGER)
  @JoinTable(
    name = "user_roles",
    joinColumns = @JoinColumn(name = "user_id"),
    inverseJoinColumns = @JoinColumn(name = "role_id")
  )
  private Set<Role> roles;
  
  @CreationTimestamp
  @Column(name = "created_at")
  private LocalDateTime createdAt;
}

@Entity
@Table(name = "roles")
public class Role {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;
  
  @Column(unique = true, nullable = false)
  private String name; // ADMIN, USER, MANAGER
  
  private String description;
  
  @ManyToMany(mappedBy = "roles")
  private Set<User> users;
  
  @ManyToMany(fetch = FetchType.EAGER)
  @JoinTable(
    name = "role_permissions",
    joinColumns = @JoinColumn(name = "role_id"),
    inverseJoinColumns = @JoinColumn(name = "permission_id")
  )
  private Set<Permission> permissions;
}

@Entity
@Table(name = "permissions")
public class Permission {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;
  
  @Column(unique = true, nullable = false)
  private String name; // DELETE_USER, CREATE_USER, etc.
  
  private String description;
  
  @ManyToMany(mappedBy = "permissions")
  private Set<Role> roles;
}
```

**Why this design?**
1. **Normalization**: No data duplication
2. **Flexibility**: Easy to add roles and permissions
3. **Scalability**: Can handle thousands of users
4. **Security**: Role-based access is industry standard
5. **Maintainability**: Clear relationships between entities

This is how enterprise databases are designed!"

---

## SECTION 9: ENTRA ID INTEGRATION

### Q12: "How does Entra ID (Azure AD) integrate with this system?"

**Answer**: [See ENTRA_ID_SETUP.md for detailed guide]

OAuth2 flow: User → Entra ID login → Backend exchanges code for token → Create JWT → Frontend uses JWT

---

## SECTION 10: COMMON INTERVIEW QUESTIONS & ANSWERS

### Q: "What's the biggest security concern in this system?"

**A**: Token theft. If someone steals the JWT:
- They can impersonate the user for 15 min
- After that, they need the refresh token
- We mitigate by:
  1. Using HTTPS (token encrypted in transit)
  2. Short expiration (15 min damage limit)
  3. HTTP-only cookies for refresh token (can't be stolen by JavaScript)
  4. CORS validation (only allowed domains)
  5. Regular token rotation

### Q: "How would you scale this to 1 million users?"

**A**:
1. Database: Shard users table by user ID range
2. Cache: Redis for token validation (don't hit DB every request)
3. Backend: Load balance multiple Spring Boot instances
4. Frontend: CDN for Angular dist files
5. Auth: Use managed service like Entra ID instead of custom DB

### Q: "What if database goes down?"

**A**:
- User already has JWT token (valid for 15 min)
- Can still make requests (JWT validation doesn't need DB)
- When token expires, can't refresh → Forced to login
- This is why token-based auth is better than session-based

### Q: "How do you handle password reset?"

**A**:
1. User clicks "Forgot Password"
2. Enters email → Generate temp reset token
3. Send reset link with token to email
4. User clicks link → Enters new password
5. Backend validates reset token, updates password in DB
6. User logs in with new password

### Q: "Can users login from multiple devices?"

**A**: Yes!
- Each login creates new JWT + refresh tokens
- User can have multiple valid tokens (one per device)
- To logout from all devices: Revoke all refresh tokens in DB

### Q: "How do you prevent brute force attacks?"

**A**:
1. Limit login attempts (5 attempts per minute)
2. Lock account after N failed attempts
3. Add CAPTCHA after failed attempts
4. Log failed login attempts
5. Alert user of suspicious activity

---

## FINAL TIPS FOR INTERVIEW

**1. Know your architecture cold**
- Be able to draw diagram on whiteboard
- Explain each component's role
- Explain how they interact

**2. Use real examples**
- Instead of "tokens expire," say "Access token expires in 15 minutes, so if stolen, attacker only has 15 minute window"
- Instead of "roles are checked," say "When user with USER role tries to access /api/admin/users, Spring Security checks if USER has ADMIN role, and returns 403 Forbidden if not"

**3. Be ready to discuss trade-offs**
- JWT vs Sessions: JWT is stateless (scalable) but can't revoke instantly
- Short tokens vs Long tokens: Short is more secure but worse UX
- Database vs Cache: Database is authoritative, cache is fast

**4. Show you understand security**
- Passwords hashed with BCrypt
- Tokens signed with secret key
- Tokens have expiration
- Refresh tokens in HTTP-only cookies
- HTTPS only in production
- CORS validation
- Session timeout

**5. Be ready to code**
- Write quick login endpoint
- Write JWT validation
- Write Auth guard
- Write HTTP interceptor

**6. Explain why your choices matter**
- Not just "we use JWT," but "we use JWT because it's stateless and scales horizontally"
- Not just "we have roles," but "we have roles because it's standard in enterprise and easier to manage than individual permissions"

---

**Good luck with interviews!** 🚀

You now understand enterprise authentication completely. This knowledge alone will make you stand out!
