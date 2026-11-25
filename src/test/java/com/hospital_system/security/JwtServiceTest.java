package com.hospital_system.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import org.junit.jupiter.api.Test;

class JwtServiceTest {

  private static final String SECRET = "test-secret-test-secret-test-secret-123456";

  private final JwtService jwtService = new JwtService(SECRET, 60, Clock.systemUTC());

  @Test
  void generatedToken_canBeParsed() {
    String token = jwtService.generateToken(7, 3, "jane", List.of("PATIENT_READ"));

    Claims claims = jwtService.parse(token);

    assertThat(claims.getSubject()).isEqualTo("7");
    assertThat(claims.get("staffId", Integer.class)).isEqualTo(3);
    assertThat(claims.get("userName", String.class)).isEqualTo("jane");
    assertThat(claims.get("permissions", List.class)).containsExactly("PATIENT_READ");
  }

  @Test
  void userWithoutStaffRecord_hasNoStaffIdClaim() {
    String token = jwtService.generateToken(7, null, "jane", List.of());

    Claims claims = jwtService.parse(token);

    assertThat(claims.get("staffId")).isNull();
  }

  @Test
  void tamperedToken_isRejected() {
    String token = jwtService.generateToken(7, 3, "jane", List.of());

    assertThatThrownBy(() -> jwtService.parse(token + "x")).isInstanceOf(JwtException.class);
  }

  @Test
  void tokenSignedWithAnotherSecret_isRejected() {
    JwtService other =
        new JwtService("another-secret-another-secret-12345678", 60, Clock.systemUTC());
    String token = other.generateToken(7, 3, "jane", List.of());

    assertThatThrownBy(() -> jwtService.parse(token)).isInstanceOf(JwtException.class);
  }

  @Test
  void expiredToken_isRejected() {
    Clock longAgo = Clock.fixed(Instant.parse("2020-01-01T00:00:00Z"), ZoneOffset.UTC);
    JwtService oldService = new JwtService(SECRET, 60, longAgo);
    String token = oldService.generateToken(7, 3, "jane", List.of());

    assertThatThrownBy(() -> jwtService.parse(token)).isInstanceOf(JwtException.class);
  }
}
