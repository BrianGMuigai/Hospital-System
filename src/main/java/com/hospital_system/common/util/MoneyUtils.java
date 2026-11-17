package com.hospital_system.common.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

public final class MoneyUtils {

  private MoneyUtils() {}

  public static BigDecimal round(BigDecimal amount) {
    return amount.setScale(2, RoundingMode.HALF_UP);
  }
}
