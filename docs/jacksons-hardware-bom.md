# Jacksons Retreat — Holiday Park MVP Hardware BOM

All figures are planning allowances in NZD, generally GST-inclusive where public retail pricing was available. Final supplier/integrator quotes are required before purchase.

## Assumptions

- 1 entry lane + 1 exit lane
- 1 shared services-building access point for toilets/showers
- 1 sauna access point
- 1 hot-tub area access point
- 11 cabin key handovers plus 1 spare smart keybox
- 18 powered RV sites monitored for electricity usage
- Existing network/power reused where practical

## 1. Vehicle entry / exit

### ANPR
Recommended class: Hikvision DeepinView 4MP ANPR/LPR bullet camera, 2.8–12mm or 8–32mm depending mounting geometry.

Planning allowance:
- 2 cameras: NZ$3,300–4,700 total

Required characteristics:
- IP67 / outdoor
- PoE
- night / low-light ANPR
- alarm I/O or API/event integration
- local whitelist/event fallback desirable
- 10–40m plate capture geometry depending lens

### Boom barriers
Public NZ retail examples put 4–5m boom barriers around NZ$4,900 each incl GST before site installation.

Planning allowance:
- 2 barriers: NZ$9,800–12,500
- safety radar/loops/photocells: NZ$1,200–2,400
- controller/relay interface: NZ$1,200–2,500
- civil/electrical/network/install: NZ$5,000–10,000

Vehicle-access installed allowance:
**NZ$20,000–30,000**

If Jacksons' existing gate hardware can be retained and only the controller/ANPR layer is replaced, this can reduce materially.

## 2. Facility access — toilets/showers, sauna, hot tubs

Recommended pilot pattern:
- networked door controller
- outdoor reader
- PIN support for guests
- NFC/mobile fallback
- electric strike/maglock
- door contact
- request-to-exit
- FastKiwi time-window entitlement

A current NZ example is the UniFi Access G3 Starter Kit / Pro class. The basic G3 kit is roughly NZ$670–700 retail; Pro hardware with PIN-capable reader is roughly NZ$1,200–1,400 per controlled door before lock hardware/install.

Planning for 3 controlled access points:
- access kits/controllers/readers: NZ$3,700–4,500
- electric strikes/maglocks/contacts/enclosures: NZ$1,200–2,100
- PoE/cabling/install: NZ$2,500–4,500

Facility-access installed allowance:
**NZ$7,500–11,000**

Soft launch should automate access only. Do not switch sauna or hot-tub heating directly unless the equipment manufacturer provides a supported low-voltage enable interface and a licensed electrician designs it.

## 3. Cabin key handover

Recommended class: igloohome Keybox 3 or equivalent commercial PMS-integrated smart keybox.

Required:
- offline PIN operation
- expiring/time-bound PIN
- API/PMS integration path
- IP66 outdoor rating
- activity logs
- emergency power
- physical override/admin process

Public retail/import pricing observed around NZ$324 each before shipping/import charges. Use a planning allowance of NZ$330–450 per unit.

For 11 cabins + 1 spare:
- 12 keyboxes: NZ$4,000–5,400
- mounting/weather-protected bank/signage: NZ$500–1,200

Key handover allowance:
**NZ$4,500–6,600**

## 4. RV-site power monitoring

### Soft-launch recommendation
Monitor usage first; remote power cut-off comes later.

For an 18-site park:
- one metering channel per powered site
- DIN-rail mounted
- Ethernet/Modbus/local API preferred
- readings stored against reservation + site
- licensed electrician to verify switchboard topology

Public 2026 NZ pricebook examples:
- Shelly Pro 3EM: about NZ$285.70
- Shelly Pro EM-50: about NZ$267.80
- Eastron SDM630-Modbus: about NZ$275 retail example

Exact meter count depends on how the 18 site circuits are grouped.

Planning allowance:
- metering hardware: NZ$2,500–4,500
- CTs/meters/enclosures/networking: NZ$1,000–2,000
- electrician/install/configuration: NZ$3,000–5,000

RV monitoring allowance:
**NZ$6,500–11,500**

For a future productised power-control version, assess TallyKey T4/T6 + TallyWeb because it is specifically designed for holiday parks and supports remote power/water monitoring and control. Quote required.

## 5. Network / resilience

Allow:
- managed PoE switch
- outdoor-rated Ethernet/fibre
- UPS
- surge protection
- weatherproof enclosures
- backup local access logic
- LTE/secondary WAN only if required

Allowance:
**NZ$2,500–5,000**

Use fibre or a wireless bridge instead of copper runs beyond normal Ethernet distance limits.

## Jacksons MVP installed budget

| System | Planning range |
|---|---:|
| Entry + exit ANPR/barriers | NZ$20,000–30,000 |
| Toilets/showers + sauna + hot-tub access | NZ$7,500–11,000 |
| 12 smart keyboxes | NZ$4,500–6,600 |
| 18-site RV power monitoring | NZ$6,500–11,500 |
| Core network/UPS/enclosures | NZ$2,500–5,000 |
| **Base installed range** | **NZ$41,000–64,100** |

Add 10–15% project contingency for trenching, switchboard changes, mounting steel, weatherproofing and unexpected site works.

**Recommended Jacksons working budget: NZ$45,000–74,000 installed.**

A smaller bench/field pilot using one lane, one facility door, one lockbox and 1–2 power circuits should be completed before ordering the full rollout.

## Purchase sequence

1. Buy one ANPR camera, one access controller/reader, one smart keybox and one metering sample.
2. Bench-connect all four device classes to FastKiwi.
3. Install one real gate lane + one facility access point + one cabin keybox + two RV circuits.
4. Run real bookings through the golden flow.
5. Only then order the full Jacksons quantity.
