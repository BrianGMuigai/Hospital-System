package com.hospital_system.identity.repository;

import com.hospital_system.identity.entity.RolePermission;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface RolePermissionRepository extends JpaRepository<RolePermission, Integer> {

  boolean existsByRoleIdAndPermissionId(Integer roleId, Integer permissionId);

  Optional<RolePermission> findByRoleIdAndPermissionId(Integer roleId, Integer permissionId);

  @Query("select rp from RolePermission rp join fetch rp.permission where rp.role.id =:roleId")
  List<RolePermission> findWithPermissionByRoleId(@Param("roleId") Integer roleId);
}
