package com.hospital_system.identity.controller;

import com.hospital_system.common.api.ApiResponse;
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

  @PostMapping
  public ResponseEntity<ApiResponse<RoleResponse>> create(
      @Valid @RequestBody CreateRoleRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponse.ok(roleService.createRole(request)));
  }

  @GetMapping
  public ApiResponse<List<RoleResponse>> list() {
    return ApiResponse.ok(roleService.listRoles());
  }

  @GetMapping("/{id}")
  public ApiResponse<RoleResponse> get(@PathVariable Integer id) {
    return ApiResponse.ok(roleService.getRole(id));
  }

  @PostMapping("/{roleId}/permissions/{permissionId}")
  public ApiResponse<RoleResponse> addPermission(
      @PathVariable Integer roleId, @PathVariable Integer permissionId) {
    return ApiResponse.ok(roleService.addPermission(roleId, permissionId));
  }

  @DeleteMapping("/{roleId}/permissions/{permissionId}")
  public ApiResponse<RoleResponse> removePermission(
      @PathVariable Integer roleId, @PathVariable Integer permissionId) {
    return ApiResponse.ok(roleService.removePermission(roleId, permissionId));
  }

  @PostMapping("/assignments")
  public ResponseEntity<ApiResponse<StaffRoleService>> assign(
      @Valid @RequestBody AssignRoleRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponse.ok(staffRoleService.assignRole(request, null)));
  }

  @PatchMapping("/assignments/{staffRoleId}/end")
  public ApiResponse<StaffRoleResponse> end(
      @PathVariable Integer staffRoleId,
      @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
    return ApiResponse.ok(staffRoleService.endRole(staffRoleId, endDate));
  }

  @GetMapping("/assignments/staff/{staffId}")
  public ApiResponse<List<StaffRoleResponse>> activeRoles(@PathVariable Integer staffId) {
    return ApiResponse.ok(staffRoleService.getActiveRoles(staffId));
  }
}
