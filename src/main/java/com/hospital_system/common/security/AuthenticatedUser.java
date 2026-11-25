package com.hospital_system.common.security;

public record AuthenticatedUser(Integer userId, Integer staffId, String userName) {}
