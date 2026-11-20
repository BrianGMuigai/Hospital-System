package com.hospital_system.identity.repository;

import com.hospital_system.identity.entity.StaffRole;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface StaffRoleRepository extends JpaRepository<StaffRole, Integer> {

  List<StaffRole> findByStaffId(Integer staffId);

  boolean existsByStaffIdAndRoleIdAndValidToIsNull(Integer staffId, Integer roleId);

  @Query(
      """
      select sr from StaffRole sr
      join fetch sr.role
      where sr.staffId  = :staffId
         and sr.validFrom <= :date
         and (sr.validTo is null or sr.validTo >= :date)
      """)
  List<StaffRole> findActiveByStaffId(
      @Param("staffId") Integer staffId, @Param("date") LocalDate date);
}
