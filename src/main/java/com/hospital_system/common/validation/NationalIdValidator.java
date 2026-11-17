package com.hospital_system.common.validation;

import java.util.regex.Pattern;

public final class NationalIdValidator {

  private static final Pattern NATIONAL_ID = Pattern.compile("^\\d{7,8}$");

  private NationalIdValidator() {}

  public static boolean isValid(String id) {
    return id != null && NATIONAL_ID.matcher(id.trim()).matches();
  }
}
