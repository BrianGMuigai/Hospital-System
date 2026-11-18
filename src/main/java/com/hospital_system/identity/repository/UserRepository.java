package com.hospital_system.identity.repository;

import com.hospital_system.identity.entity.User;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Integer> {

  Optional<User> findByUserName(String userName);

  boolean existsByUserName(String userName);

  boolean existsByUserEmail(String userEmail);
}
