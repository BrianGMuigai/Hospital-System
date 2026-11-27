package com.hospital_system.hr.repository;

import com.hospital_system.hr.entity.Department;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DepartmentRepository extends JpaRepository<Department, Integer> {

  boolean existsByDepartmentName(String departmentName);
}
