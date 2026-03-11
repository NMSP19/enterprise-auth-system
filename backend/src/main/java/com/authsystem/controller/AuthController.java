package com.authsystem.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.authsystem.dto.LoginRequest;
import com.authsystem.dto.LoginResponse;
import com.authsystem.service.JwtService;

import java.util.Arrays;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "http://localhost:4200")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;

    public AuthController(AuthenticationManager authenticationManager, JwtService jwtService) {
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        try {
            // For demo purposes: hardcoded credentials
            if ("admin".equals(request.getUsername()) && "admin123".equals(request.getPassword())) {
                String accessToken = jwtService.generateAccessToken("admin", Arrays.asList("ADMIN"));
                String refreshToken = jwtService.generateRefreshToken("admin", Arrays.asList("ADMIN"));
                
                LoginResponse response = LoginResponse.builder()
                    .accessToken(accessToken)
                    .refreshToken(refreshToken)
                    .tokenType("Bearer")
                    .expiresIn(900)
                    .username("admin")
                    .email("admin@example.com")
                    .roles(Arrays.asList("ADMIN"))
                    .build();
                
                return ResponseEntity.ok(response);
            } else if ("user".equals(request.getUsername()) && "user123".equals(request.getPassword())) {
                String accessToken = jwtService.generateAccessToken("user", Arrays.asList("USER"));
                String refreshToken = jwtService.generateRefreshToken("user", Arrays.asList("USER"));
                
                LoginResponse response = LoginResponse.builder()
                    .accessToken(accessToken)
                    .refreshToken(refreshToken)
                    .tokenType("Bearer")
                    .expiresIn(900)
                    .username("user")
                    .email("user@example.com")
                    .roles(Arrays.asList("USER"))
                    .build();
                
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.status(401).build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(401).build();
        }
    }

    @PostMapping("/refresh")
    public ResponseEntity<?> refresh(@RequestHeader(value = "Authorization") String token) {
        try {
            if (token.startsWith("Bearer ")) {
                token = token.substring(7);
            }
            
            if (jwtService.isTokenValid(token)) {
                String username = jwtService.extractUsername(token);
                java.util.List<String> roles = jwtService.extractRoles(token);
                String newAccessToken = jwtService.generateAccessToken(username, roles);
                
                return ResponseEntity.ok(new TokenRefreshResponse(newAccessToken, "Bearer", 900));
            }
            return ResponseEntity.status(401).build();
        } catch (Exception e) {
            return ResponseEntity.status(401).build();
        }
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout() {
        return ResponseEntity.ok("Logged out successfully");
    }

    // Inner class for refresh response
    @lombok.Data
    @lombok.AllArgsConstructor
    public static class TokenRefreshResponse {
        private String accessToken;
        private String tokenType;
        private long expiresIn;
    }
}
