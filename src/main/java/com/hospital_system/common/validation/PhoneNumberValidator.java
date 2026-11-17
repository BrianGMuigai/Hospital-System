package com.hospital_system.common.validation;

import java.util.regex.Pattern;

public final class PhoneNumberValidator {

  private static final Pattern KENYA_PHONE = Pattern.compile("^(?:\\+254|254|0)[17]\\d{8}$");

  private PhoneNumberValidator() {}

  public static boolean isValid(String phone) {
    return phone != null && KENYA_PHONE.matcher(phone.trim()).matches();
  }

  public static String normalize(String phone) {
    String trimmed = phone.trim();
    if (trimmed.startsWith("+254")) return trimmed;
    if (trimmed.startsWith("254")) return "+" + trimmed;
    return "+254" + trimmed.substring(1);
  }
}
