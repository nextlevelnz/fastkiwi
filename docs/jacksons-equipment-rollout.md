# Jacksons Retreat — Equipment Rollout & Purchase Gates

## Purpose
This document is the procurement companion to the Jacksons Launch Command Center in FastKiwi. It keeps hardware purchasing behind test and approval gates so Jacksons does not bulk-buy equipment before the software/hardware golden path is proven.

## Stage 1 — Software and site survey first
Before installing hardware:
- finish the Jacksons map calibration;
- map AbodeBooking / Channex inventory IDs to physical Jacksons units and sites;
- photograph and measure the entry/exit lane;
- map power/network routes;
- have a licensed electrician identify RV circuits and switchboards;
- survey one cabin key location and one shared-facility door.

No permanent access-control change is made at this stage.

## Stage 2 — Buy one bench kit
Buy/quote only one of each test item:
- 1 × Hikvision DS-TCG406-E ANPR camera, or approved current equivalent;
- 1 × igloohome Keybox 3;
- 1 × Shelly Pro EM-50;
- 1 × PoE switch;
- 1 × UPS;
- 1 × suitable weatherproof/network enclosure;
- 1 × commercial PIN/RFID access controller + reader after the pilot door survey.

Do not yet buy:
- second ANPR camera;
- boom barriers;
- bulk keyboxes;
- bulk RV meters;
- all facility readers/locks.

## Stage 3 — Bench acceptance
FastKiwi must prove:
- ANPR plate event reaches FastKiwi;
- known/unknown plate decisions work;
- keybox time-bound guest PIN can be created and expires correctly;
- access credential can be issued/expired;
- power meter reports the correct circuit and energy values;
- all actions create audit events;
- network loss has a safe fallback path.

## Stage 4 — Mini field pilot
Install:
- one cabin/keybox workflow;
- one shared-facility access point;
- one ANPR observation point without relying on a permanent barrier;
- two RV circuits monitored through the approved electrical design.

Run real end-to-end test:
booking → map assignment → access entitlement → arrival → usage → checkout → key return → housekeeping → ready.

## Stage 5 — Shared facilities
After pilot approval, roll out:
- toilets/showers access;
- sauna access;
- hot-tub access;
- staff override;
- timed cleaning closure;
- free egress / emergency access.

## Stage 6 — Roofed accommodation
After one keybox has passed the field pilot:
- audit every roofed unit;
- determine final keybox/digital-lock quantity;
- bulk order only the approved quantity;
- link each device to an exact unit;
- test cleaner/admin handoff and expired guest access.

## Stage 7 — RV power
After the two-circuit pilot:
- electrician maps every site circuit;
- choose final meter topology per switchboard;
- monitor usage first;
- do not enable remote mains switching until separately designed and approved.

## Stage 8 — Entry / Exit
Only after the ANPR camera is proven in Jacksons conditions:
- buy the second ANPR camera;
- select final entry and exit barriers;
- install anti-fall radar/loops/photocells;
- provide manual emergency release;
- keep fallback sequence: ANPR → PIN → remote open → physical emergency release.

## Stage 9 — Soft launch
Run with staff fallback and logging before unattended operation.

## Current first-buy candidates
### ANPR
Hikvision DS-TCG406-E — candidate because it supports vehicle access control functions, relay outputs and integration interfaces. Confirm current NZ/AU availability and integrator support before ordering.

### Cabin key handover
igloohome Keybox 3 — candidate because it supports time-sensitive/offline PIN access and API integration. Confirm API account and commercial terms before bulk ordering.

### RV energy monitoring
Shelly Pro EM-50 — candidate for the pilot because it is DIN-rail mounted, two-channel, single-phase and exposes local integration options. Installation must be designed and completed by a suitably licensed electrician.

## Purchase rule
**Buy one → integrate → bench test → field test → approve → scale.**
