package com.hospital_system.identity.service;

import com.hospital_system.common.events.EventPublisher;
import com.hospital_system.common.exception.BusinessRuleException;
import com.hospital_system.common.exception.ConflictException;
import com.hospital_system.common.exception.NotFoundException;
import com.hospital_system.identity.dto.CreateUserRequest;
import com.hospital_system.identity.dto.UserResponse;
import com.hospital_system.identity.entity.User;
import com.hospital_system.identity.event.UserCreated;
import com.hospital_system.identity.event.UserDeactivated;
import com.hospital_system.identity.repository.UserRepository;
import java.time.Clock;
import java.time.OffsetDateTime;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

  private final UserRepository userRepository;
  private final PasswordEncoder passwordEncoder;
  private final EventPublisher eventPublisher;
  private final Clock clock;

  public UserService(
      UserRepository userRepository,
      PasswordEncoder passwordEncoder,
      EventPublisher eventPublisher,
      Clock clock) {
    this.userRepository = userRepository;
    this.passwordEncoder = passwordEncoder;
    this.eventPublisher = eventPublisher;
    this.clock = clock;
  }

  @Transactional
  public UserResponse createUser(CreateUserRequest request) {
    String userName = request.userName().trim();
    String email = request.userEmail().trim().toLowerCase();

    if (userRepository.existsByUserName(userName)) {
      throw new ConflictException("User name is already taken ");
    }
    if (userRepository.existsByUserEmail(email)) {
      throw new ConflictException("Email is already in use ");
    }

    User saved =
        userRepository.save(
            new User(
                userName,
                email,
                passwordEncoder.encode(request.password()),
                OffsetDateTime.now(clock)));
    eventPublisher.publish(new UserCreated(saved.getId(), saved.getUserName()));
    return UserResponse.from(saved);
  }

  @Transactional(readOnly = true)
  public UserResponse getUser(Integer id) {
    return UserResponse.from(findUser(id));
  }

  @Transactional(readOnly = true)
  public Page<UserResponse> listUsers(Pageable pageable) {
    return userRepository.findAll(pageable).map(UserResponse::from);
  }

  @Transactional
  public void deactivateUser(Integer id) {
    User user = findUser(id);
    if (!user.isActive()) {
      throw new BusinessRuleException("User is alrady deactivated");
    }
    user.deactivate();
    eventPublisher.publish(new UserDeactivated(id));
  }

  private User findUser(Integer id) {
    return userRepository.findById(id).orElseThrow(() -> new NotFoundException("User", id));
  }
}
