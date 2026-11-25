package com.hospital_system.common.security;

import com.hospital_system.common.exception.UnauthorizedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public final class CurrentUser {

  private CurrentUser() {}

  public static AuthenticatedUser get() {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    if (auth == null || !(auth.getPrincipal() instanceof AuthenticatedUser user)) {
      throw new UnauthorizedException("Not authenticated");
    }
    return user;
  }
}
