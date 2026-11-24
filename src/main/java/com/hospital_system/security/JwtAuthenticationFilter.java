package com.hospital_system.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

public class JwtAuthenticationFilter extends OncePerRequestFilter {

  private final JwtService jwtService;

  public JwtAuthenticationFilter(JwtService jwtService) {
    this.jwtService = jwtService;
  }

  @Override
  protected void doFilterInternal(
      HttpServletRequest request, HttpServletResponse response, FilterChain chain)
      throws ServletException, IOException {

    String header = request.getHeader("Authorization");
    if (header != null && header.startsWith("Bearer")) {
      try {
        Claims claims = jwtService.parse(header.substring(7));

        List<?> raw = claims.get(JwtService.CLAIM_PERMISSIONS, List.class);
        List<SimpleGrantedAuthority> authorities =
            raw == null
                ? List.of()
                : raw.stream().map(p -> new SimpleGrantedAuthority(String.valueOf(p))).toList();

        AuthenticatedUser principal =
            new AuthenticatedUser(
                Integer.valueOf(claims.getSubject()),
                claims.get(JwtService.CLAIM_USER_NAME, String.class));

        SecurityContextHolder.getContext()
            .setAuthentication(
                new UsernamePasswordAuthenticationToken(principal, null, authorities));
      } catch (JwtException | IllegalArgumentException e) {

        SecurityContextHolder.clearContext();
      }
    }
    chain.doFilter(request, response);
  }
}
