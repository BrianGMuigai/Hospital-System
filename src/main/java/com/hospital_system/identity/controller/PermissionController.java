package com.hospital_system.identity.controller;

import com.hospital_system.common.api.ApiResponse;
import com.hospital_system.identity.dto.PermissionResponse;
import com.hospital_system.identity.service.PermissionService;
import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/permissions")
public class PermissionController {

  private final PermissionService permissionService;

  public PermissionController(PermissionService permissionService) {
    this.permissionService = permissionService;
  }

  @PreAuthorize("hasAuthority('PERMISSION_READ')")
  @GetMapping
  public ApiResponse<List<PermissionResponse>> list() {
    return ApiResponse.ok(permissionService.listPermissions());
  }
}
