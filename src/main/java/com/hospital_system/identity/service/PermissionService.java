package com.hospital_system.identity.service;

import com.hospital_system.identity.dto.PermissionResponse;
import com.hospital_system.identity.repository.PermissionRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PermissionService {

  private final PermissionRepository permissionRepository;

  public PermissionService(PermissionRepository permissionRepository) {
    this.permissionRepository = permissionRepository;
  }

  @Transactional(readOnly = true)
  public List<PermissionResponse> listPermissions() {
    return permissionRepository.findAll().stream().map(PermissionResponse::from).toList();
  }
}
