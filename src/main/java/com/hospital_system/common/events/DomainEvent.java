package com.hospital_system.common.events;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

public abstract class DomainEvent {

  private final UUID eventId = UUID.randomUUID();
  private final OffsetDateTime occuredAt = OffsetDateTime.now(ZoneOffset.UTC);

  public UUID getEventId() {
    return eventId;
  }

  public OffsetDateTime getOccurredAt() {
    return occuredAt;
  }
}
