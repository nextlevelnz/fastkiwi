# Jacksons Retreat FastKiwi Pilot — Approval-Gated Project Plan

## Project rule

We build one verified layer at a time. No major hardware purchase, permanent wiring, live access-control change, or guest-facing release happens without an explicit approval checkpoint.

Every stage follows:

**Question → Decision → Build → Test → Review → APPROVE / REVISE → Next stage**

The Jacksons pilot remains focused on holiday-park automation only:
- booking-linked self check-in
- interactive park map / guest guide
- vehicle entry and exit
- cabin / house / batch key handover
- toilets and showers access
- sauna and hot-tub timed access
- RV-site power monitoring
- housekeeping and staff handoff
- facility cleaning lock schedules

Everything else stays in the roadmap but is not a soft-launch dependency.

---

## Phase 0 — Project controls and source of truth

### Goal
Freeze the Jacksons MVP scope and establish the source-of-truth data we will use.

### Inputs required
- current booking/PMS inventory export or screenshots
- current Jacksons paper map
- exact cabin / house / batch names
- exact powered / undercover / tent site names
- current gate/barrier photos and controller details
- current switchboard / powered-site circuit layout
- current key handling process
- current toilet/shower/sauna/hot-tub doors and locks

### Deliverables
- master inventory register
- property device register
- facility register
- naming standard
- approval log
- unresolved-questions log

### Approval Gate 0
Owner/manager confirms the master inventory and MVP scope are correct.

---

## Phase 1 — Jacksons digital map

### Goal
Turn the paper map into a clean interactive digital park map.

### Steps
1. Import the paper map as the builder background.
2. Trace the park road, entry, exit and main walking paths.
3. Place the Services Building, office/reception and common facilities.
4. Place every cabin / house / batch.
5. Place every powered, undercover powered and tent site.
6. Place sauna, hot tubs, dump station and other MVP facilities.
7. Place both glow-worm areas, waterfall walk and quartz mine walk.
8. Add labels, icons and guest-facing descriptions.
9. Draw driving and walking routes.
10. Preview on desktop, kiosk and mobile.

### Deliverables
- Jacksons Main Map draft
- exact map nodes
- route graph
- guest guide content
- mobile/kiosk preview

### Approval Gate 1
Jacksons confirms every object is in the correct physical location and the map is safe to publish as a navigation aid.

---

## Phase 2 — Booking inventory to map linking

### Goal
Make every booking resolve to the correct physical map location.

### Steps
1. Import exact PMS inventory IDs/names.
2. Create FastKiwi unit/site IDs.
3. Match each PMS item to one FastKiwi unit/site.
4. Link the unit/site to the map node.
5. Set accommodation type and capacity.
6. Mark whether housekeeping is required.
7. Mark whether a keybox is required.
8. Mark whether RV electricity monitoring is required.
9. Test sample bookings against every inventory type.
10. Create mismatch/error handling.

### Deliverables
- PMS ↔ FastKiwi ↔ Map mapping
- housekeeping flags
- keybox flags
- power-monitoring flags

### Approval Gate 2
Jacksons approves the complete inventory mapping and verifies sample bookings point to the correct locations.

---

## Phase 3 — Guest self check-in and personalised stay page

### Goal
Give each guest a private FastKiwi arrival/stay page.

### Steps
1. Booking lookup by booking number + surname/verification.
2. Registration details.
3. Vehicle plate capture.
4. Arrival time / late-arrival flow.
5. Park rules and acknowledgement.
6. Show booked accommodation/site.
7. Show personalised map route.
8. Show relevant facilities and activities.
9. Offer sauna/hot-tub add-ons.
10. Display access/key information only after authorization.
11. Checkout instructions.

### Deliverables
- online self check-in
- kiosk-ready self check-in
- private stay page
- personalised guest map

### Approval Gate 3
Jacksons signs off the guest flow, wording, rules and what guests can/cannot see.

---

## Phase 4 — Bench hardware proof

### Goal
Prove one sample of each hardware class before bulk ordering.

### Bench kit
- 1 ANPR camera
- 1 gate/controller interface
- 1 facility access controller/reader
- 1 smart keybox
- 1–2 RV power-metering channels
- PoE/network/UPS components

### Tests
- FastKiwi receives ANPR events
- FastKiwi can approve/deny access
- PIN/QR time windows work
- keybox code can be issued and expire
- RV kWh readings reach FastKiwi
- device-offline events are detected
- manual fallback works

### Approval Gate 4
Only after the bench test passes do we approve field installation and larger hardware quantities.

---

## Phase 5 — Mini field pilot at Jacksons

### Goal
Install the smallest real guest-facing pilot.

### Initial field scope
- one gate lane
- one real facility access point
- one cabin/house/batch keybox
- 1–2 powered-site meter channels
- one real housekeeping turnover

### Test journey
Booking
→ self check-in
→ vehicle plate
→ map
→ gate access
→ key/facility access
→ stay
→ checkout/key return
→ cleaner notification
→ cleaning complete
→ admin ready notification
→ power usage closeout

### Approval Gate 5
Run controlled real stays. Do not expand until the full golden path is reliable.

---

## Phase 6 — Shared facilities rollout

### Goal
Deploy toilets/showers and paid wellness access.

### Scope
- toilets/showers access
- sauna timed access
- hot-tub timed access
- cleaning closure schedules
- staff override
- free egress
- guest pre-closure notices
- live open/closed status in guest map

### Approval Gate 6
Jacksons confirms facility schedules, safety, alternate toilet arrangements and staff override process.

---

## Phase 7 — Cabin/house/batch key rollout + housekeeping

### Goal
Automate key handover and cleaning handoff for roofed accommodation.

### Flow
Reservation
→ keybox assignment
→ time-bound PIN
→ key collected
→ checkout/key returned
→ accommodation DIRTY
→ cleaner notified
→ cleaner starts/completes
→ damage/maintenance escalation if needed
→ accommodation READY
→ admin/reception notified

Powered/tent sites remain excluded from accommodation-turnover cleaning unless explicitly configured.

### Approval Gate 7
Jacksons verifies every roofed unit has the correct keybox and cleaner workflow.

---

## Phase 8 — RV power monitoring rollout

### Goal
Monitor real consumption per powered site.

### Steps
1. Electrician maps circuits.
2. Confirm meter architecture.
3. Install monitoring.
4. Link meter/channel to FastKiwi site ID.
5. Start reading at booking/arrival.
6. Monitor kWh during stay.
7. Close reading at departure.
8. Produce operator report.

Remote power enable/disable remains a later option after monitoring is proven.

### Approval Gate 8
Jacksons confirms power readings match the physical meters and correct guest/site.

---

## Phase 9 — Full entry / exit rollout

### Goal
Complete entry and exit automation.

### Scope
- entry ANPR
- exit ANPR
- barriers/gates
- safety detection
- booking validity windows
- plate allowlist
- PIN fallback
- remote-open
- physical emergency override
- full event logging

### Approval Gate 9
Jacksons approves live unattended vehicle access after supervised testing.

---

## Phase 10 — Soft launch

### Goal
Put FastKiwi into normal Jacksons operations with human supervision.

### Soft-launch metrics
- successful self-check-in %
- ANPR success %
- manual intervention rate
- failed-access rate
- cleaner turnaround time
- room-ready notification time
- sauna/hot-tub booking usage
- RV kWh mapping accuracy
- guest support contacts per 100 stays
- system/device uptime

### Approval Gate 10
Jacksons decides whether the system is ready to become the reference production installation.

---

## Phase 11 — Productise for other holiday parks

### Goal
Convert Jacksons into a repeatable FastKiwi holiday-park product.

### Product modules
- FastKiwi Map Builder
- FastKiwi Guest / Self Check-In
- FastKiwi Gate
- FastKiwi Keys
- FastKiwi Facility Access
- FastKiwi Wellness Access
- FastKiwi RV Power
- FastKiwi Housekeeping / Staff

### Client onboarding
1. Create property.
2. Import PMS inventory.
3. Upload existing park map.
4. Build/trace map.
5. Link inventory.
6. Configure access/facilities.
7. Install hardware kit.
8. Test.
9. Publish.
10. Go live.

---

# How we will work together

For each stage I will:
1. tell you exactly what we are about to do;
2. ask only the questions needed for that stage;
3. prepare/build the work;
4. show you the result;
5. ask for **APPROVE** or **REVISE**;
6. only then move to the next stage.

For hardware or irreversible operational changes I will stop before purchase/install/live activation and ask for explicit approval.

# Current stage

**We are now at Phase 0 / Phase 1: source-of-truth inventory + Jacksons digital map.**

The immediate objective is to establish the exact Jacksons inventory and trace the real paper map accurately.
