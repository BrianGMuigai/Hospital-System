package com.hospital_system.security;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class SecurityIntegrationTest {

  @Autowired MockMvc mockMvc;
  @Autowired JwtService jwtService;

  private String bearer(List<String> permissions) {
    return "Bearer " + jwtService.generateToken(1, 1, "tester", permissions);
  }

  @Test
  void health_isOpen() throws Exception {
    mockMvc.perform(get("/api/health")).andExpect(status().isOk());
  }

  @Test
  void noToken_isUnauthorized() throws Exception {
    mockMvc.perform(get("/api/users")).andExpect(status().isUnauthorized());
  }

  @Test
  void tokenWithoutPermission_isForbidden() throws Exception {
    mockMvc
        .perform(get("/api/users").header("Authorization", bearer(List.of())))
        .andExpect(status().isForbidden());
  }

  @Test
  void tokenWithPermission_isAllowed() throws Exception {
    mockMvc
        .perform(get("/api/users").header("Authorization", bearer(List.of("USER_READ"))))
        .andExpect(status().isOk());
  }
}
