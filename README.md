# FastKiwi

FastKiwi is the operating and development platform for automated tourism accommodation.

It connects bookings, payments, guest access, IoT devices, facilities, utilities, staff workflows, vending, analytics, suppliers, property development and show-home sales in one system.

## First live deployment

**Jacksons Retreat Alpine Holiday Park — West Coast, New Zealand**

Primary production path:

```
Booking
  -> payment / entitlement check
  -> guest + vehicle identity
  -> QR / PIN / ANPR credentials
  -> interactive park map
  -> gate / accommodation / facility access
  -> paid amenity usage
  -> checkout
  -> housekeeping
  -> reporting
```

## Platform modules

FastKiwi OS · Map · Access · Pay · Control · CRM · Scout · Marketplace · ShowHome · Match · Quote · Stay

## Architecture principles

- Multi-property and multi-tenant from the start
- Event-driven automation
- External systems isolated behind adapters
- Desired device state separated from actual device state
- Audit logs for operational and security events
- Offline/degraded fallbacks for access-critical workflows
- No production secrets committed to GitHub

See `docs/architecture.md`, `docs/data-model.md`, and `docs/jacksons-pilot.md`.
