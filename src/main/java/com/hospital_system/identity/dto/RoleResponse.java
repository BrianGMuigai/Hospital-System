package com.hospital_system.identity.dto;

import com.hospital_system.identity.entity.Role;
import java.util.List;

public record RoleResponse(
    Integer roleId, String roleName, String roleDescription, List<String> permissions) {

  public static RoleResponse from(Role role, List<String> permissions) {
    return new RoleResponse(
        role.getId(), role.getRoleName(), role.getRoleDescription(), permissions);
  }
}
