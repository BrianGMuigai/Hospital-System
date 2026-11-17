package com.hospital_system.common.util;

import java.time.LocalDate;

public final class DateRangeUtils {

  private DateRangeUtils() {}

  public static boolean overlaps(
      java.time.LocalDate startA, LocalDate endA, java.time.LocalDate startB, LocalDate endB) {
    return !startA.isAfter(endB) && !startB.isAfter(endA);
  }
}
