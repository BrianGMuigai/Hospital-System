package com.hospital_system.identity.service;

import com.hospital_system.common.events.EventPublisher;
import com.hospital_system.common.exception.BusinessRuleException;
import com.hospital_system.common.exception.ConflictException;
import com.hospital_system.common.exception.NotFoundException;
import com.hospital_system.identity.dto.AssignRoleRequest;
import com.hospital_system.identity.dto.StaffRoleResponse;
import com.hospital_system.identity.entity.Role;
import com.hospital_system.identity.entity.StaffRole;
import com.hospital_system.identity.event.RoleAssigned;
import com.hospital_system.identity.repository.RoleRepository;
import com.hospital_system.identity.repository.StaffRoleRepository;
import java.time.Clock;
import java.time.LocalDate;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class StaffRoleService {

  private final StaffRoleRepository staffRoleRepository;
  private final RoleRepository roleRepository;
  private final EventPublisher eventPublisher;
  private final Clock clock;

  public StaffRoleService(
      StaffRoleRepository staffRoleRepository,
      RoleRepository roleRepository,
      EventPublisher eventPublisher,
      Clock clock) {
    this.staffRoleRepository = staffRoleRepository;
    this.roleRepository = roleRepository;
    this.eventPublisher = eventPublisher;
    this.clock = clock;
  }

  @Transactional
  public StaffRoleResponse assignRole(AssignRoleRequest request, Integer assignedBy) {
    Role role =
        roleRepository
            .findById(request.roleId())
            .orElseThrow(() -> new NotFoundException("Role", request.roleId()));

    if (request.validTo() != null && request.validTo().isBefore(request.validFrom())) {
      throw new BusinessRuleException("validTo cannot be before validFrom");
    }
    if (request.validTo() == null
        && staffRoleRepository.existsByStaffIdAndRoleIdAndValidToIsNull(
            request.staffId(), request.roleId())) {
      throw new ConflictException("Staff member already hold  this role");
    }

    StaffRole saved =
        staffRoleRepository.save(
            new StaffRole(
                request.staffId(),
                role,
                request.departmentId(),
                request.validFrom(),
                request.validTo(),
                assignedBy));
    eventPublisher.publish(new RoleAssigned(request.staffId(), role.getId(), assignedBy));
    return StaffRoleResponse.from(saved);
  }

  @Transactional
  public StaffRoleResponse endRole(Integer staffRoleId, LocalDate endDate) {
    StaffRole staffRole =
        staffRoleRepository
            .findById(staffRoleId)
            .orElseThrow(() -> new NotFoundException("StaffRole", staffRoleId));
    if (endDate.isBefore(staffRole.getValidFrom())) {
      throw new BusinessRuleException("End date cannot be before the start date");
    }
    staffRole.end(endDate);
    return StaffRoleResponse.from(staffRole);
  }

  @Transactional(readOnly = true)
  public List<StaffRoleResponse> getActiveRoles(Integer staffId) {
    return staffRoleRepository.findActiveByStaffId(staffId, LocalDate.now(clock)).stream()
        .map(StaffRoleResponse::from)
        .toList();
  }
}
