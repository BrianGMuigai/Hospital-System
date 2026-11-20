package com.hospital_system.identity.repository;

import com.hospital_system.identity.entity.Permission;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PermissionRepository extends JpaRepository<Permission, Integer> {

  Optional<Permission> findByPermissionCode(String permissionCode);

  boolean existsByPermissionCode(String permissionCode);
}
