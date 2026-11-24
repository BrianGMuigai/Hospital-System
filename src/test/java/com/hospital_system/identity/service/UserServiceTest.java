package com.hospital_system.identity.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.hospital_system.common.events.EventPublisher;
import com.hospital_system.common.exception.BusinessRuleException;
import com.hospital_system.common.exception.ConflictException;
import com.hospital_system.common.exception.NotFoundException;
import com.hospital_system.identity.dto.CreateUserRequest;
import com.hospital_system.identity.entity.User;
import com.hospital_system.identity.repository.UserRepository;
import java.time.Clock;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

  @Mock UserRepository userRepository;
  @Mock EventPublisher eventPublisher;

  private final PasswordEncoder encoder = new BCryptPasswordEncoder();
  private final Clock clock = Clock.fixed(Instant.parse("2026-11-24T08:00:00Z"), ZoneOffset.UTC);

  private UserService service;

  @BeforeEach
  void setUp() {
    service = new UserService(userRepository, encoder, eventPublisher, clock);
  }

  private CreateUserRequest request() {
    return new CreateUserRequest("jane", "Jane@Example.com", "Secret123!");
  }

  @Test
  void createUser_duplicateUserName_throwsConflict() {
    when(userRepository.existsByUserName("jane")).thenReturn(true);

    assertThatThrownBy(() -> service.createUser(request())).isInstanceOf(ConflictException.class);

    verify(userRepository, never()).save(any());
  }

  @Test
  void createUser_duplicateEmail_throwsConflict() {
    when(userRepository.existsByUserName("jane")).thenReturn(false);
    when(userRepository.existsByUserEmail("jane@example.com")).thenReturn(true);

    assertThatThrownBy(() -> service.createUser(request())).isInstanceOf(ConflictException.class);

    verify(userRepository, never()).save(any());
  }

  @Test
  void createUser_storesHashedPasswordAndLowercasedEmail() {
    when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));

    service.createUser(request());

    ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
    verify(userRepository).save(captor.capture());
    User saved = captor.getValue();

    assertThat(saved.getUserEmail()).isEqualTo("jane@example.com");
    assertThat(saved.getPasswordHash()).isNotEqualTo("Secret123!");
    assertThat(encoder.matches("Secret123!", saved.getPasswordHash())).isTrue();
  }

  @Test
  void deactivateUser_alreadyInactive_throwsBusinessRule() {
    User user = new User("jane", "jane@example.com", "hash", OffsetDateTime.now(clock));
    user.deactivate();
    when(userRepository.findById(1)).thenReturn(Optional.of(user));

    assertThatThrownBy(() -> service.deactivateUser(1)).isInstanceOf(BusinessRuleException.class);
  }

  @Test
  void deactivateUser_unknownId_throwsNotFound() {
    when(userRepository.findById(99)).thenReturn(Optional.empty());

    assertThatThrownBy(() -> service.deactivateUser(99)).isInstanceOf(NotFoundException.class);
  }
}
