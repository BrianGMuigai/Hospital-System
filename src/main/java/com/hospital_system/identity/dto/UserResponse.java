package com.hospital_system.identity.dto;

import com.hospital_system.identity.entity.User;
import java.time.OffsetDateTime;

public record UserResponse(
    Integer userId, String userName, String userEmail, boolean active, OffsetDateTime createdAt) {

  public static UserResponse from(User user) {
    return new UserResponse(
        user.getId(),
        user.getUserName(),
        user.getUserEmail(),
        user.isActive(),
        user.getCreatedAt());
  }
}
