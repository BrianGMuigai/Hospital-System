package com.hospital_system.security;

import java.util.List;

public record LoginResponse(
    String token, Integer userId, String userName, List<String> permissions) {}
