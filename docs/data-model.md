# FastKiwi Canonical Data Model

Initial Supabase domains:

- Organisation: organisations, organisation_members, properties, property_members
- Accommodation: accommodation_units, rate_plans
- Guest/booking: guests, reservations, reservation_guests, vehicles, reservation_vehicles, payments
- Access/facilities: facilities, access_credentials, facility_entitlements, access_events
- IoT: devices, device_states, device_commands, device_events
- Operations: tasks, work_orders
- Commerce: inventory_items, sales, sale_items
- Utilities: meter_readings, charging_sessions
- Marketplace/development: suppliers, products, quotes, quote_items, leads
- Automation: automation_events, automation_jobs, webhook_deliveries, audit_logs

Every operational record is scoped to an organisation and, where relevant, a property.

Automation events use an event type, aggregate, payload, idempotency key, correlation ID, causation ID and processing status.
