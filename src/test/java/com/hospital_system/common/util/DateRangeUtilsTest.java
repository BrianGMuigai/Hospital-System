package com.hospital_system.common.util;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;
import org.junit.jupiter.api.Test;

class DateRangeUtilsTest {

  @Test
  void rangesThatShareADayOverlap() {
    assertThat(
            DateRangeUtils.overlaps(
                LocalDate.of(2026, 12, 1),
                LocalDate.of(2026, 12, 5),
                LocalDate.of(2026, 12, 5),
                LocalDate.of(2026, 12, 9)))
        .isTrue();
  }

  @Test
  void separateRangesDoNotOverlap() {
    assertThat(
            DateRangeUtils.overlaps(
                LocalDate.of(2026, 12, 1),
                LocalDate.of(2026, 12, 4),
                LocalDate.of(2026, 12, 5),
                LocalDate.of(2026, 12, 9)))
        .isFalse();
  }
}
