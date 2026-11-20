package com.hospital_system.identity.repository;

import com.hospital_system.identity.entity.Role;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RoleRepository extends JpaRepository<Role, Integer> {

  Optional<Role> findByRoleName(String roleName);

  boolean existsByRoleName(String roleName);
}
