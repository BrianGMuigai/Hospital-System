package com.hospital_system.hr.repository;

import com.hospital_system.hr.entity.Staff;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StaffRepository extends JpaRepository<Staff, Integer> {

  boolean existsByEmployeeId(String employeeId);

  boolean existsByUserId(Integer userId);

  Optional<Staff> nfindByUserId(Integer userId);

  @Override
  @EntityGraph(attributePaths = {"department", "employeeType", "employmentType"})
  Page<Staff> findAll(Pageable pageable);

  @EntityGraph(attributePaths = {"department", "employeeType", "employmentType"})
  Page<Staff> findByDepartmentId(Integer departmentId, Pageable pageable);
}
