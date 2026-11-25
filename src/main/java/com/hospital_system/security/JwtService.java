package com.hospital_system.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtBuilder;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.List;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class JwtService {

  public static final String CLAIM_USER_NAME = "userName";
  public static final String CLAIM_PERMISSIONS = "permissions";
  public static final String CLAIM_STAFF_ID = "staffId";

  private final SecretKey key;
  private final long expirationMinutes;
  private final Clock clock;

  public JwtService(
      @Value("${app.jwt.secret}") String secret,
      @Value("${app.jwt.expiration-minutes}") long expirationMinutes,
      Clock clock) {
    this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    this.expirationMinutes = expirationMinutes;
    this.clock = clock;
  }

  public String generateToken(
      Integer userId, Integer staffId, String userName, List<String> permissions) {
    Instant now = clock.instant();
    JwtBuilder builder =
        Jwts.builder()
            .subject(String.valueOf(userId))
            .claim(CLAIM_USER_NAME, userName)
            .claim(CLAIM_PERMISSIONS, permissions)
            .issuedAt(Date.from(now))
            .expiration(Date.from(now.plus(expirationMinutes, ChronoUnit.MINUTES)));
    if (staffId != null) {
      builder.claim(CLAIM_STAFF_ID, staffId);
    }
    return builder.signWith(key).compact();
  }

  public Claims parse(String token) {
    return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
  }
}
