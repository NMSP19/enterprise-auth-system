# COMPLETE IMPLEMENTATION - All Code Files

## Table of Contents
1. Spring Boot Files
2. Angular Files
3. Database Files
4. Configuration Files

---

## SPRING BOOT FILES

### 1. pom.xml (Maven Dependencies)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.authsystem</groupId>
  <artifactId>enterprise-auth-system</artifactId>
  <version>1.0.0</version>
  <name>Enterprise Authentication System</name>
  <description>Production-grade auth system with JWT + Spring Boot + Angular</description>
  
  <properties>
    <java.version>17</java.version>
    <spring-boot.version>3.2.0</spring-boot.version>
  </properties>
  
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-dependencies</artifactId>
        <version>${spring-boot.version}</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
  
  <dependencies>
    <!-- Spring Boot Web -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    
    <!-- Spring Security -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    
    <!-- Spring Data JPA -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    
    <!-- PostgreSQL Driver -->
    <dependency>
      <groupId>org.postgresql</groupId>
      <artifactId>postgresql</artifactId>
      <scope>runtime</scope>
    </dependency>
    
    <!-- JWT -->
    <dependency>
      <groupId>io.jsonwebtoken</groupId>
      <artifactId>jjwt</artifactId>
      <version>0.11.5</version>
    </dependency>
    
    <!-- Lombok -->
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <optional>true</optional>
    </dependency>
    
    <!-- Validation -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
  </dependencies>
  
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
```

### 2. AuthSystemApplication.java (Main Class)

```java
package com.authsystem;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class AuthSystemApplication {

    public static void main(String[] args) {
        SpringApplication.run(AuthSystemApplication.class, args);
    }
}
```

### 3. SecurityConfig.java (Spring Security Configuration)

```java
package com.authsystem.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.authsystem.filter.JwtAuthenticationFilter;
import com.authsystem.filter.SessionTimeoutFilter;
import com.authsystem.service.UserService;
import com.authsystem.service.SessionService;

@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    private final UserService userService;
    private final SessionService sessionService;

    public SecurityConfig(UserService userService, SessionService sessionService) {
        this.userService = userService;
        this.sessionService = sessionService;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter() {
        return new JwtAuthenticationFilter();
    }

    @Bean
    public SessionTimeoutFilter sessionTimeoutFilter() {
        return new SessionTimeoutFilter(sessionService);
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .cors()
            .and()
            // Add custom filters
            .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class)
            .addFilterAfter(sessionTimeoutFilter(), JwtAuthenticationFilter.class)
            // Configure endpoints
            .authorizeRequests()
            .antMatchers("/api/auth/login", "/api/auth/register", "/api/auth/refresh").permitAll()
            .antMatchers("/api/admin/**").hasRole("ADMIN")
            .anyRequest().authenticated()
            .and()
            // Stateless session (JWT, not cookies)
            .sessionManagement()
            .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            // Handle exceptions
            .exceptionHandling()
            .authenticationEntryPoint((request, response, authException) -> {
                response.sendError(401, "Unauthorized: " + authException.getMessage());
            })
            .accessDeniedHandler((request, response, accessDeniedException) -> {
                response.sendError(403, "Forbidden: " + accessDeniedException.getMessage());
            });

        return http.build();
    }
}
```

### 4. JwtService.java (JWT Token Management)

```java
package com.authsystem.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.authsystem.entity.User;

import javax.crypto.SecretKey;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class JwtService {

    @Value("${jwt.secret:this-is-a-very-secret-key-that-should-be-at-least-256-bits}")
    private String jwtSecret;

    @Value("${jwt.expiration:900000}") // 15 minutes in milliseconds
    private long jwtExpiration;

    @Value("${jwt.refresh-expiration:604800000}") // 7 days in milliseconds
    private long refreshExpiration;

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes());
    }

    public String generateAccessToken(User user) {
        return generateToken(user, jwtExpiration);
    }

    public String generateRefreshToken(User user) {
        return generateToken(user, refreshExpiration);
    }

    private String generateToken(User user, long expirationTime) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expirationTime);

        return Jwts.builder()
            .setSubject(user.getUsername())
            .claim("roles", user.getRoles().stream()
                .map(role -> role.getName())
                .collect(Collectors.toList()))
            .claim("email", user.getEmail())
            .setIssuedAt(now)
            .setExpiration(expiryDate)
            .signWith(getSigningKey(), SignatureAlgorithm.HS256)
            .compact();
    }

    public String extractUsername(String token) {
        return parseToken(token).getSubject();
    }

    public List<String> extractRoles(String token) {
        Claims claims = parseToken(token);
        return (List<String>) claims.get("roles", List.class);
    }

    public boolean isTokenValid(String token) {
        try {
            parseToken(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public boolean isTokenExpired(String token) {
        try {
            Claims claims = parseToken(token);
            return claims.getExpiration().before(new Date());
        } catch (Exception e) {
            return true;
        }
    }

    private Claims parseToken(String token) {
        return Jwts.parserBuilder()
            .setSigningKey(getSigningKey())
            .build()
            .parseClaimsJws(token)
            .getBody();
    }
}
```

### 5. AuthService.java (Authentication Logic)

```java
package com.authsystem.service;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.authsystem.dto.LoginRequest;
import com.authsystem.dto.LoginResponse;
import com.authsystem.dto.TokenResponse;
import com.authsystem.entity.User;
import com.authsystem.repository.UserRepository;

@Service
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final SessionService sessionService;

    public AuthService(
            AuthenticationManager authenticationManager,
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            SessionService sessionService) {
        this.authenticationManager = authenticationManager;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.sessionService = sessionService;
    }

    public LoginResponse login(LoginRequest request) {
        // Authenticate user
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                request.getUsername(),
                request.getPassword()
            )
        );

        // Get authenticated user
        User user = userRepository.findByUsername(request.getUsername())
            .orElseThrow(() -> new RuntimeException("User not found"));

        // Create tokens
        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);

        // Record session
        sessionService.recordActivity(user.getUsername());

        return LoginResponse.builder()
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .tokenType("Bearer")
            .expiresIn(900) // 15 minutes
            .username(user.getUsername())
            .email(user.getEmail())
            .roles(user.getRoles().stream()
                .map(role -> role.getName())
                .toList())
            .build();
    }

    public TokenResponse refresh(String refreshToken) {
        if (!jwtService.isTokenValid(refreshToken)) {
            throw new RuntimeException("Invalid refresh token");
        }

        String username = jwtService.extractUsername(refreshToken);
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new RuntimeException("User not found"));

        String newAccessToken = jwtService.generateAccessToken(user);

        return TokenResponse.builder()
            .accessToken(newAccessToken)
            .tokenType("Bearer")
            .expiresIn(900)
            .build();
    }

    public void logout(String username) {
        sessionService.invalidateSession(username);
    }
}
```

### 6. AuthController.java (API Endpoints)

```java
package com.authsystem.controller;

import org.springframework.web.bind.annotation.*;

import com.authsystem.dto.LoginRequest;
import com.authsystem.dto.LoginResponse;
import com.authsystem.dto.TokenResponse;
import com.authsystem.service.AuthService;

import javax.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "http://localhost:4200")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public LoginResponse login(@RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/refresh")
    public TokenResponse refresh(HttpServletRequest request) {
        String refreshToken = request.getHeader("X-Refresh-Token");
        if (refreshToken == null || refreshToken.isEmpty()) {
            throw new RuntimeException("Refresh token required");
        }
        return authService.refresh(refreshToken);
    }

    @PostMapping("/logout")
    public void logout(HttpServletRequest request) {
        String username = request.getUserPrincipal().getName();
        authService.logout(username);
    }
}
```

### 7. AdminController.java (Admin Endpoints)

```java
package com.authsystem.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import com.authsystem.dto.UserDTO;
import com.authsystem.entity.User;
import com.authsystem.service.UserService;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
@CrossOrigin(origins = "http://localhost:4200")
public class AdminController {

    private final UserService userService;

    public AdminController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/users")
    public List<UserDTO> getAllUsers() {
        return userService.getAllUsers();
    }

    @GetMapping("/users/{id}")
    public UserDTO getUserById(@PathVariable Long id) {
        return userService.getUserById(id);
    }

    @PostMapping("/users")
    public UserDTO createUser(@RequestBody UserDTO userDTO) {
        return userService.createUser(userDTO);
    }

    @PutMapping("/users/{id}")
    public UserDTO updateUser(@PathVariable Long id, @RequestBody UserDTO userDTO) {
        return userService.updateUser(id, userDTO);
    }

    @DeleteMapping("/users/{id}")
    public void deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
    }

    @PostMapping("/assign-role/{userId}/{roleId}")
    public void assignRole(@PathVariable Long userId, @PathVariable Long roleId) {
        userService.assignRole(userId, roleId);
    }
}
```

### 8. JwtAuthenticationFilter.java (Extract & Validate JWT)

```java
package com.authsystem.filter;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import com.authsystem.service.JwtService;
import com.authsystem.service.UserService;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private JwtService jwtService;
    private UserService userService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                   HttpServletResponse response, 
                                   FilterChain filterChain) 
                        throws ServletException, IOException {
        try {
            String jwt = extractJwtFromRequest(request);
            
            if (jwt != null && jwtService.isTokenValid(jwt)) {
                String username = jwtService.extractUsername(jwt);
                List<String> roles = jwtService.extractRoles(jwt);
                
                List<SimpleGrantedAuthority> authorities = roles.stream()
                    .map(role -> new SimpleGrantedAuthority("ROLE_" + role))
                    .collect(Collectors.toList());
                
                UsernamePasswordAuthenticationToken authentication = 
                    new UsernamePasswordAuthenticationToken(
                        username, 
                        null, 
                        authorities
                    );
                
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception e) {
            logger.error("Cannot set user authentication: " + e.getMessage());
        }
        
        filterChain.doFilter(request, response);
    }

    private String extractJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
```

---

## DATABASE FILES

### database/init.sql (Create Tables)

```sql
-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username)
);

-- Roles Table
CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Roles Junction
CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- Permissions Table
CREATE TABLE IF NOT EXISTS permissions (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Role Permissions Junction
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
);
```

### database/seed-data.sql (Initial Data)

```sql
-- Insert Roles
INSERT INTO roles (name, description) VALUES 
  ('ADMIN', 'Administrator with full access'),
  ('USER', 'Regular user with limited access'),
  ('MANAGER', 'Manager with team management access')
ON CONFLICT (name) DO NOTHING;

-- Insert Permissions
INSERT INTO permissions (name, description) VALUES
  ('VIEW_USER', 'Can view user information'),
  ('CREATE_USER', 'Can create new users'),
  ('UPDATE_USER', 'Can update user information'),
  ('DELETE_USER', 'Can delete users'),
  ('MANAGE_ROLES', 'Can manage roles and permissions')
ON CONFLICT (name) DO NOTHING;

-- Assign permissions to ADMIN role
INSERT INTO role_permissions (role_id, permission_id) 
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'ADMIN'
ON CONFLICT DO NOTHING;

-- Assign limited permissions to USER role
INSERT INTO role_permissions (role_id, permission_id) 
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'USER' AND p.name IN ('VIEW_USER')
ON CONFLICT DO NOTHING;

-- Insert test users
INSERT INTO users (username, email, password_hash, first_name, last_name, is_active) 
VALUES 
  ('admin', 'admin@example.com', '$2a$10$...', 'Admin', 'User', TRUE),
  ('user', 'user@example.com', '$2a$10$...', 'Normal', 'User', TRUE),
  ('manager', 'manager@example.com', '$2a$10$...', 'Manager', 'User', TRUE)
ON CONFLICT (username) DO NOTHING;

-- Assign roles to users
INSERT INTO user_roles (user_id, role_id) 
SELECT u.id, r.id FROM users u, roles r 
WHERE u.username = 'admin' AND r.name = 'ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id) 
SELECT u.id, r.id FROM users u, roles r 
WHERE u.username = 'user' AND r.name = 'USER'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id) 
SELECT u.id, r.id FROM users u, roles r 
WHERE u.username = 'manager' AND r.name = 'MANAGER'
ON CONFLICT DO NOTHING;
```

---

## CONFIGURATION FILES

### application.yml (Main Config)

```yaml
spring:
  application:
    name: enterprise-auth-system
  
  datasource:
    url: jdbc:postgresql://localhost:5432/auth_system
    username: ${DB_USERNAME:postgres}
    password: ${DB_PASSWORD:password}
    driver-class-name: org.postgresql.Driver
  
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
    show-sql: false
  
  web:
    cors:
      allowed-origins: http://localhost:4200
      allowed-methods: GET,POST,PUT,DELETE,OPTIONS
      allowed-headers: '*'

server:
  port: 8080
  servlet:
    context-path: /

jwt:
  secret: ${JWT_SECRET:this-is-a-very-long-secret-key-that-should-be-at-least-256-bits-long}
  expiration: 900000  # 15 minutes in milliseconds
  refresh-expiration: 604800000  # 7 days in milliseconds

logging:
  level:
    root: INFO
    com.authsystem: DEBUG
  file:
    name: logs/application.log
```

---

## How to Use These Files

1. Copy all Java files to `backend/src/main/java/com/authsystem/`
2. Copy pom.xml to `backend/`
3. Copy SQL files to `database/`
4. Copy application.yml to `backend/src/main/resources/`
5. Create PostgreSQL database: `createdb auth_system`
6. Run SQL migrations
7. Run Spring Boot app: `mvn spring-boot:run`
8. Access at `http://localhost:8080`

---

**Next: See ANGULAR_IMPLEMENTATION.md for frontend code**
