package com.hospital_system.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

import com.hospital_system.common.exception.UnauthorizedException;
import com.hospital_system.identity.entity.User;
import com.hospital_system.identity.repository.UserRepository;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

  @Mock UserRepository userRepository;
  @Mock PermissionLoader permissionLoader;
  @Mock JwtService jwtService;

  private final PasswordEncoder encoder = new BCryptPasswordEncoder();
  private AuthService service;

  @BeforeEach
  void setUp() {
    service = new AuthService(userRepository, encoder, permissionLoader, jwtService);
  }

  private User user() {
    return new User("jane", "jane@x.com", encoder.encode("Secret123!"), OffsetDateTime.now());
  }

  @Test
  void login_unknownUser_isRejected() {
    when(userRepository.findByUserName("ghost")).thenReturn(Optional.empty());

    assertThatThrownBy(() -> service.login(new LoginRequest("ghost", "Secret123!")))
        .isInstanceOf(UnauthorizedException.class);
  }

  @Test
  void login_wrongPassword_isRejected() {
    when(userRepository.findByUserName("jane")).thenReturn(Optional.of(user()));

    assertThatThrownBy(() -> service.login(new LoginRequest("jane", "wrong")))
        .isInstanceOf(UnauthorizedException.class);
  }

  @Test
  void login_deactivatedUser_isRejected() {
    User user = user();
    user.deactivate();

    when(userRepository.findByUserName("jane")).thenReturn(Optional.of(user));

    assertThatThrownBy(() -> service.login(new LoginRequest("jane", "Secret123!")))
        .isInstanceOf(UnauthorizedException.class);
  }

  @Test
  void login_validCredentials_returnsTokenAndPermissions() {
    when(userRepository.findByUserName("jane")).thenReturn(Optional.of(user()));

    when(permissionLoader.loadPermissions(any())).thenReturn(List.of("PATIENT_READ"));

    when(jwtService.generateToken(any(), any(), eq("jane"), eq(List.of("PATIENT_READ"))))
        .thenReturn("the-token");

    LoginResponse response = service.login(new LoginRequest("jane", "Secret123!"));

    assertThat(response.token()).isEqualTo("the-token");
    assertThat(response.permissions()).containsExactly("PATIENT_READ");
  }
}
