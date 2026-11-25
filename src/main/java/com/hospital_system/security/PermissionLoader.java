package com.hospital_system.security;

import java.time.Clock;
import java.time.LocalDate;
import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class PermissionLoader {

  private static final String SQL =
      """
      SELECT DISTINCT p.PermissionCode
      FROM Staff s
      JOIN StaffRoles sr ON sr.StaffId = s.StaffId
      JOIN RolesPermission rp ON rp.RolesId = sr.RolesId
      JOIN Permissions p ON p.PermissionId = rp.PermissionsId
      WHERE s.UserId = ?
        AND sr.ValidFrom <= ?
        AND (sr.ValidTo IS NULL OR sr.ValidTo >= ?)
      ORDER BY p.PermissionCode
      """;

  private final JdbcTemplate jdbc;
  private final Clock clock;

  public PermissionLoader(JdbcTemplate jdbc, Clock clock) {
    this.jdbc = jdbc;
    this.clock = clock;
  }

  public List<String> loadPermissions(Integer userId) {
    LocalDate today = LocalDate.now(clock);
    return jdbc.queryForList(SQL, String.class, userId, today, today);
  }

  public Integer findStaffId(Integer userId) {
    List<Integer> ids =
        jdbc.queryForList("SELECT StaffId FROM Staff WHERE UserId = ?", Integer.class, userId);
    return ids.isEmpty() ? null : ids.get(0);
  }
}
