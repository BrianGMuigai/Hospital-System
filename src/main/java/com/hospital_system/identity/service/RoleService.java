package com.hospital_system.identity.service;

import com.hospital_system.common.exception.ConflictException;
import com.hospital_system.common.exception.NotFoundException;
import com.hospital_system.identity.dto.CreateRoleRequest;
import com.hospital_system.identity.dto.RoleResponse;
import com.hospital_system.identity.entity.Permission;
import com.hospital_system.identity.entity.Role;
import com.hospital_system.identity.entity.RolePermission;
import com.hospital_system.identity.repository.PermissionRepository;
import com.hospital_system.identity.repository.RolePermissionRepository;
import com.hospital_system.identity.repository.RoleRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RoleService {

  private final RoleRepository roleRepository;
  private final PermissionRepository permissionRepository;
  private final RolePermissionRepository rolePermissionRepository;

  public RoleService(
      RoleRepository roleRepository,
      PermissionRepository permissionRepository,
      RolePermissionRepository rolePermissionRepository) {

    this.roleRepository = roleRepository;
    this.permissionRepository = permissionRepository;
    this.rolePermissionRepository = rolePermissionRepository;
  }

  @Transactional
  public RoleResponse createRole(CreateRoleRequest request) {
    String name = request.roleName().trim();
    if (roleRepository.existsByRoleName(name)) {
      throw new ConflictException("Role already exists: " + name);
    }
    Role role = roleRepository.save(new Role(name, request.roleDescription()));
    return RoleResponse.from(role, List.of());
  }

  @Transactional(readOnly = true)
  public RoleResponse getRole(Integer id) {
    return toResponse(findRole(id));
  }

  @Transactional(readOnly = true)
  public List<RoleResponse> listRoles() {
    return roleRepository.findAll().stream().map(this::toResponse).toList();
  }

  @Transactional
  public RoleResponse addPermission(Integer roleId, Integer permissionId) {
    Role role = findRole(roleId);
    Permission permission =
        permissionRepository
            .findById(permissionId)
            .orElseThrow(() -> new NotFoundException("Permission", permissionId));
    if (rolePermissionRepository.existsByRoleIdAndPermissionId(roleId, permissionId)) {
      throw new ConflictException("Role already has this permission");
    }
    rolePermissionRepository.save(new RolePermission(role, permission));
    return toResponse(role);
  }

  @Transactional
  public RoleResponse removePermission(Integer roleId, Integer permissionId) {
    Role role = findRole(roleId);
    RolePermission link =
        rolePermissionRepository
            .findByRoleIdAndPermissionId(roleId, permissionId)
            .orElseThrow(
                () -> new NotFoundException("RolePermission", roleId + "/" + permissionId));
    rolePermissionRepository.delete(link);
    return toResponse(role);
  }

  private Role findRole(Integer id) {
    return roleRepository.findById(id).orElseThrow(() -> new NotFoundException("Role", id));
  }

  private RoleResponse toResponse(Role role) {
    List<String> codes =
        rolePermissionRepository.findWithPermissionByRoleId(role.getId()).stream()
            .map(link -> link.getPermission().getPermissionCode())
            .toList();
    return RoleResponse.from(role, codes);
  }
}
