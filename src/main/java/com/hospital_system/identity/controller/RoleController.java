package com.hospital_system.identity.controller;

import com.hospital_system.common.api.ApiResponse;
import com.hospital_system.common.security.CurrentUser;
import com.hospital_system.identity.dto.AssignRoleRequest;
import com.hospital_system.identity.dto.CreateRoleRequest;
import com.hospital_system.identity.dto.RoleResponse;
import com.hospital_system.identity.dto.StaffRoleResponse;
import com.hospital_system.identity.service.RoleService;
import com.hospital_system.identity.service.StaffRoleService;
import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/roles")
public class RoleController {

  private final RoleService roleService;
  private final StaffRoleService staffRoleService;

  public RoleController(RoleService roleService, StaffRoleService staffRoleService) {
    this.roleService = roleService;
    this.staffRoleService = staffRoleService;
  }

  @PreAuthorize("hasAuthority('ROLE_WRITE')")
  @PostMapping
  public ResponseEntity<ApiResponse<RoleResponse>> create(
      @Valid @RequestBody CreateRoleRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponse.ok(roleService.createRole(request)));
  }

  @PreAuthorize("hasAuthority('ROLE_READ')")
  @GetMapping
  public ApiResponse<List<RoleResponse>> list() {
    return ApiResponse.ok(roleService.listRoles());
  }

  @PreAuthorize("hasAuthority('ROLE_READ')")
  @GetMapping("/{id}")
  public ApiResponse<RoleResponse> get(@PathVariable Integer id) {
    return ApiResponse.ok(roleService.getRole(id));
  }

  @PreAuthorize("hasAuthority('ROLE_WRITE')")
  @PostMapping("/{roleId}/permissions/{permissionId}")
  public ApiResponse<RoleResponse> addPermission(
      @PathVariable Integer roleId, @PathVariable Integer permissionId) {
    return ApiResponse.ok(roleService.addPermission(roleId, permissionId));
  }

  @PreAuthorize("hasAuthority('ROLE_WRITE')")
  @DeleteMapping("/{roleId}/permissions/{permissionId}")
  public ApiResponse<RoleResponse> removePermission(
      @PathVariable Integer roleId, @PathVariable Integer permissionId) {
    return ApiResponse.ok(roleService.removePermission(roleId, permissionId));
  }

  @PreAuthorize("hasAuthority('ROLE_WRITE')")
  @PostMapping("/assignments")
  public ResponseEntity<ApiResponse<StaffRoleService>> assign(
      @Valid @RequestBody AssignRoleRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponse.ok(staffRoleService.assignRole(request, CurrentUser.get().staffId())));
  }

  @PreAuthorize("hasAuthority('ROLE_WRITE')")
  @PatchMapping("/assignments/{staffRoleId}/end")
  public ApiResponse<StaffRoleResponse> end(
      @PathVariable Integer staffRoleId,
      @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
    return ApiResponse.ok(staffRoleService.endRole(staffRoleId, endDate));
  }

  @PreAuthorize("hasAuthority('ROLE_READ')")
  @GetMapping("/assignments/staff/{staffId}")
  public ApiResponse<List<StaffRoleResponse>> activeRoles(@PathVariable Integer staffId) {
    return ApiResponse.ok(staffRoleService.getActiveRoles(staffId));
  }
}
