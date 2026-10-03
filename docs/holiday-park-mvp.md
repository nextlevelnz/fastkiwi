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
8. Cabin / house / batch cleaning and staff handoff

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
→ cabin/house/batch key returned or checkout completed
→ cleaner is notified automatically
→ accommodation becomes DIRTY / CLEANING
→ cleaner marks cleaning complete
→ admin/reception is notified that the unit is READY
→ power usage closed for RV site

Powered sites and tent sites do not create housekeeping turnover tasks unless explicitly configured to do so.

## Housekeeping workflow

Housekeeping is part of the core MVP for roofed accommodation.

Eligible inventory must have `housekeeping_required=true`. Typical examples:
- cabins
- houses
- batches
- The Barn
- self-contained accommodation
- future show-home accommodation

Typical non-housekeeping inventory:
- powered RV sites
- undercover powered sites
- tent sites

### Trigger
A turnover is created when either:
- a cabin key is returned to the FastKiwi lockbox; or
- a reservation is marked checked out/completed.

FastKiwi deduplicates these triggers so the same stay does not create two cleaning jobs.

### Cleaner handoff
The system:
1. marks the accommodation `dirty`;
2. creates a housekeeping task;
3. notifies the cleaner/cleaning team;
4. shows the unit in the cleaner queue;
5. records cleaning start/completion times.

### Admin handoff
When the cleaner marks the turnover completed:
1. the accommodation status becomes `ready`;
2. the linked task closes;
3. reception/admin is notified;
4. the event `housekeeping.completed` is logged;
5. the unit is available for the next operational step.

Later this can support:
- inspection-required status
- linen/restock checklists
- damage reporting
- maintenance escalation
- photos after cleaning
- cleaner performance/timing metrics

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
- Key-return event triggers housekeeping for housekeeping-enabled accommodation

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
One gate lane, one facility door, one smart keybox, one RV meter, plus one real cabin turnover through the cleaner/admin workflow.

### Phase 2 — Jacksons rollout
Entry/exit, shared facility access, sauna/hot tubs, all cabin keyboxes, housekeeping workflow and RV monitoring.

### Phase 3 — Productise
Turn Jacksons configuration into reusable FastKiwi holiday-park templates, onboarding, hardware kits and subscription plans.

## Acceptance tests

- Reservation creates valid arrival access
- Unknown/expired plate does not open gate
- PIN fallback works without reception intervention
- Sauna/hot-tub credential only works in paid window
- Lockbox PIN expires automatically
- Key return creates one cleaning task for housekeeping-enabled accommodation
- Powered/tent sites do not create cleaning tasks
- Cleaner completion marks the unit ready
- Admin/reception receives the ready notification
- RV site kWh is recorded against the correct booking/site
- Checkout disables access and closes utility allocation
- Every action creates an auditable event
