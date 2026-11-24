package com.hospital_system.identity.service;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.hospital_system.common.events.EventPublisher;
import com.hospital_system.common.exception.BusinessRuleException;
import com.hospital_system.common.exception.ConflictException;
import com.hospital_system.common.exception.NotFoundException;
import com.hospital_system.identity.dto.AssignRoleRequest;
import com.hospital_system.identity.entity.Role;
import com.hospital_system.identity.entity.StaffRole;
import com.hospital_system.identity.repository.RoleRepository;
import com.hospital_system.identity.repository.StaffRoleRepository;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class StaffRoleServiceTest {

  @Mock StaffRoleRepository staffRoleRepository;
  @Mock RoleRepository roleRepository;
  @Mock EventPublisher eventPublisher;

  private final Clock clock = Clock.fixed(Instant.parse("2026-11-24T08:00:00Z"), ZoneOffset.UTC);
  private StaffRoleService service;

  @BeforeEach
  void setUp() {
    service = new StaffRoleService(staffRoleRepository, roleRepository, eventPublisher, clock);
  }

  // match the order of the fields in YOUR AssignRoleRequest record
  private AssignRoleRequest request(LocalDate from, LocalDate to) {
    return new AssignRoleRequest(1, 2, 3, from, to);
  }

  @Test
  void assignRole_unknownRole_throwsNotFound() {
    when(roleRepository.findById(2)).thenReturn(Optional.empty());

    assertThatThrownBy(() -> service.assignRole(request(LocalDate.of(2026, 12, 1), null), null))
        .isInstanceOf(NotFoundException.class);
  }

  @Test
  void assignRole_validToBeforeValidFrom_throwsBusinessRule() {
    when(roleRepository.findById(2)).thenReturn(Optional.of(new Role("Doctor", "Treats patients")));

    assertThatThrownBy(() ->
            service.assignRole(
                request(LocalDate.of(2026, 12, 10), LocalDate.of(2026, 12, 1)), null))
        .isInstanceOf(BusinessRuleException.class);

    verify(staffRoleRepository, never()).save(any(StaffRole.class));
  }

  @Test
  void assignRole_alreadyHoldsActiveRole_throwsConflict() {
    when(roleRepository.findById(2)).thenReturn(Optional.of(new Role("Doctor", "Treats patients")));
    when(staffRoleRepository.existsByStaffIdAndRoleIdAndValidToIsNull(1, 2)).thenReturn(true);

    assertThatThrownBy(() -> service.assignRole(request(LocalDate.of(2026, 12, 1), null), null))
        .isInstanceOf(ConflictException.class);

    verify(staffRoleRepository, never()).save(any(StaffRole.class));
  }
}
