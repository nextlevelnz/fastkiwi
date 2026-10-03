# FastKiwi Holiday Park MVP

## Scope lock

FastKiwi soft launch is focused only on holiday-park operations:

1. Vehicle entry and exit
2. Cabin key handover
3. Toilets and showers access
4. Sauna and hot-tub timed access
5. RV-site power monitoring
6. Booking-linked guest self check-in
7. Interactive park map linked to booked accommodation

Everything else stays in the product pipeline but is not a soft-launch dependency.

## Golden pilot flow

Booking confirmed
→ accommodation/site matched
→ guest registration
→ vehicle plate captured
→ gate authorisation created
→ cabin lockbox or site directions issued
→ facility entitlements created
→ timed sauna/hot-tub access if purchased
→ power allocation/meter session started for RV site
→ guest checks out
→ access expires
→ key return / exit logged
→ power usage closed

## MVP device classes

### Gate
- Entry ANPR camera
- Exit ANPR camera
- Boom barrier or gate relay
- Safety radar/loop
- Local fallback PIN / remote-open
- FastKiwi adapter

### Facility access
- Outdoor-capable reader
- Electric strike / maglock / gate relay
- Door contact
- Request-to-exit
- Local controller with schedule support
- PIN required; QR preferred where supported

### Cabin keys
- Smart lockbox/keybox per cabin
- Offline-valid PIN generation preferred
- PMS / booking-calendar integration capability
- Access log and expiry

### RV electricity
- Per-site or per-circuit meter
- DIN-rail installation
- Modbus TCP/RTU or local API preferred
- kWh readings available to FastKiwi
- Optional remote contactor for power enable/disable in later phase

## Soft-launch phases

### Phase 0 — Bench test
Connect one sample of every device class to FastKiwi before field installation.

### Phase 1 — Guest access pilot
One gate lane, one facility door, one smart keybox, one RV meter.

### Phase 2 — Jacksons rollout
Entry/exit, shared facility access, sauna/hot tubs, all cabin keyboxes and RV monitoring.

### Phase 3 — Productise
Turn Jacksons configuration into reusable FastKiwi holiday-park templates, onboarding, hardware kits and subscription plans.

## Acceptance tests

- Reservation creates valid arrival access
- Unknown/expired plate does not open gate
- PIN fallback works without reception intervention
- Sauna/hot-tub credential only works in paid window
- Lockbox PIN expires automatically
- RV site kWh is recorded against the correct booking/site
- Checkout disables access and closes utility allocation
- Every action creates an auditable event
