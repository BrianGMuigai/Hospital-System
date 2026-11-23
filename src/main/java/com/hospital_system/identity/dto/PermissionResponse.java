package com.hospital_system.identity.dto;

import com.hospital_system.identity.entity.Permission;

public record PermissionResponse(
    Integer permissionId, String permissionCode, String permissionDescription) {

  public static PermissionResponse from(Permission permission) {
    return new PermissionResponse(
        permission.getId(), permission.getPermissionCode(), permission.getPermissionDescription());
  }
}
