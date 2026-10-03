# FastKiwi Architecture

## Golden path

```
reservation.confirmed
  -> validate payment
  -> issue credentials
  -> authorize vehicle plate
  -> create facility entitlements
  -> generate personalized park-map route

vehicle.arrived
  -> ANPR match
  -> authorize entry
  -> open gate
  -> mark reservation ARRIVED

facility.access_requested
  -> evaluate entitlement
  -> included: unlock
  -> paid: collect payment then unlock
  -> log event

checkout.completed
  -> expire credentials
  -> remove ANPR authorization
  -> close active sessions
  -> create housekeeping task
  -> trigger review / return offer
```

## Layers

1. Experience — Base44 operator dashboard, guest map, kiosk, staff and supplier portals.
2. Domain — canonical FastKiwi property, booking, access, facility, IoT, commerce and supplier records.
3. Events — every material state change creates an auditable event and automation job.
4. Adapters — SmartBooking, Channex, payments, ANPR, gates, locks, EV, RV utilities, laundry, vending and messaging.
5. Infrastructure — Supabase PostgreSQL, Auth, Storage, Edge Functions and scheduled jobs.

## Reliability

Access-critical paths require ANPR -> PIN -> remote open -> physical emergency override, plus heartbeats, retries, dead-letter handling and audit logs.

## Security

Use RLS for user-facing tables, service-role access only on trusted server-side functions, secret stores instead of Git, least-privilege OAuth scopes and explicit retention rules for camera/ANPR data.
