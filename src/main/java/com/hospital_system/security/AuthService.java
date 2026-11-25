package com.hospital_system.security;

import com.hospital_system.common.exception.UnauthorizedException;
import com.hospital_system.identity.entity.User;
import com.hospital_system.identity.repository.UserRepository;
import java.util.List;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

  private final UserRepository userRepository;
  private final PasswordEncoder passwordEncoder;
  private final PermissionLoader permissionLoader;
  private final JwtService jwtService;

  public AuthService(
      UserRepository userRepository,
      PasswordEncoder passwordEncoder,
      PermissionLoader permissionLoader,
      JwtService jwtService) {
    this.userRepository = userRepository;
    this.passwordEncoder = passwordEncoder;
    this.permissionLoader = permissionLoader;
    this.jwtService = jwtService;
  }

  @Transactional(readOnly = true)
  public LoginResponse login(LoginRequest request) {
    User user =
        userRepository
            .findByUserName(request.userName().trim())
            .filter(User::isActive)
            .filter(u -> passwordEncoder.matches(request.password(), u.getPasswordHash()))
            .orElseThrow(() -> new UnauthorizedException("Invalid user name or password"));

    List<String> permissions = permissionLoader.loadPermissions(user.getId());
    Integer staffId = permissionLoader.findStaffId(user.getId());
    String token = jwtService.generateToken(user.getId(), staffId, user.getUserName(), permissions);
    return new LoginResponse(token, user.getId(), user.getUserName(), permissions);
  }
}
