
with fastkiwi_org as (
  insert into public.organisations (name, slug, status, timezone, metadata)
  values (
    'FastKiwi',
    'fastkiwi',
    'active',
    'Pacific/Auckland',
    jsonb_build_object('purpose','platform_internal','seeded_by','fastkiwi_foundation')
  )
  on conflict (slug) do update set
    name = excluded.name,
    status = excluded.status,
    timezone = excluded.timezone,
    metadata = public.organisations.metadata || excluded.metadata,
    updated_at = now()
  returning id
),
jacksons_org as (
  insert into public.organisations (name, slug, status, timezone, metadata)
  values (
    'Jacksons Retreat Ltd',
    'jacksons-retreat-ltd',
    'active',
    'Pacific/Auckland',
    jsonb_build_object('purpose','pilot_operator','seeded_by','fastkiwi_foundation')
  )
  on conflict (slug) do update set
    name = excluded.name,
    status = excluded.status,
    timezone = excluded.timezone,
    metadata = public.organisations.metadata || excluded.metadata,
    updated_at = now()
  returning id
),
jacksons_property as (
  insert into public.properties (
    organisation_id, name, slug, status, timezone, address, geo, external_refs, metadata
  )
  select
    id,
    'Jacksons Retreat Alpine Holiday Park',
    'jacksons-retreat',
    'active',
    'Pacific/Auckland',
    jsonb_build_object(
      'route','State Highway 73 / Great Alpine Highway',
      'region','West Coast',
      'country','New Zealand'
    ),
    jsonb_build_object(),
    jsonb_build_object(),
    jsonb_build_object(
      'pilot','FASTKIWI LIVE LAB',
      'inventory_verification_required',true,
      'map_positioning_required',true
    )
  from jacksons_org
  on conflict (organisation_id, slug) do update set
    name = excluded.name,
    status = excluded.status,
    timezone = excluded.timezone,
    address = excluded.address,
    metadata = public.properties.metadata || excluded.metadata,
    updated_at = now()
  returning id, organisation_id
),
facility_seed(code,name,facility_type,access_mode,price,status,map_node_id,metadata) as (
  values
    ('office-checkin','Office / Check-in','operations','included',0::numeric,'active','office-checkin',jsonb_build_object('guest_visible',true)),
    ('services-building','Services Building','shared_facilities','included',0::numeric,'active','services-building',jsonb_build_object('guest_visible',true)),
    ('kitchen-lounge','Kitchen & Lounge','shared_facilities','included',0::numeric,'active','kitchen-lounge',jsonb_build_object('guest_visible',true)),
    ('toilets-showers','Toilets & Showers','hygiene','included',0::numeric,'active','toilets-showers',jsonb_build_object('guest_visible',true,'future_access_mode','QR/PIN')),
    ('laundry','Laundry','laundry','payg',0::numeric,'active','laundry',jsonb_build_object('guest_visible',true,'pricing_to_confirm',true)),
    ('sauna','Wood Barrel Sauna','wellness','paid',0::numeric,'active','sauna',jsonb_build_object('guest_visible',true,'pricing_to_confirm',true)),
    ('hot-tubs','Hot Tubs','wellness','paid',0::numeric,'active','hot-tubs',jsonb_build_object('guest_visible',true,'pricing_to_confirm',true)),
    ('dump-station','Camper Dump Station','rv_service','included',0::numeric,'active','dump-station',jsonb_build_object('guest_visible',true,'departure_guidance',true)),
    ('glow-worm-1','Glow Worm Viewing Area 1','attraction','included',0::numeric,'active','glow-worm-1',jsonb_build_object('guest_visible',true)),
    ('glow-worm-2','Glow Worm Viewing Area 2','attraction','included',0::numeric,'active','glow-worm-2',jsonb_build_object('guest_visible',true)),
    ('waterfall-walk','Waterfall Walk','walking_track','included',0::numeric,'active','waterfall-walk',jsonb_build_object('guest_visible',true,'approx_walk_minutes',20)),
    ('quartz-mine-walk','Old Quartz Mine Walk','walking_track','included',0::numeric,'active','quartz-mine-walk',jsonb_build_object('guest_visible',true,'approx_walk_minutes',45)),
    ('entry-gate','Automated Entry Gate','access','included',0::numeric,'planned','entry-gate',jsonb_build_object('anpr_planned',true)),
    ('exit-gate','Automated Exit Gate','access','included',0::numeric,'planned','exit-gate',jsonb_build_object('anpr_planned',true)),
    ('self-checkin-kiosk','Self Check-in Kiosk','checkin','included',0::numeric,'planned','self-checkin-kiosk',jsonb_build_object('eftpos_planned',true)),
    ('ev-charging','EV Charging','utility','payg',0::numeric,'planned','ev-charging',jsonb_build_object('guest_visible',true,'pricing_to_confirm',true)),
    ('vending-hub','Vending / Local Produce Hub','retail','payg',0::numeric,'planned','vending-hub',jsonb_build_object('guest_visible',true)),
    ('robot-cafe','Robot Cafe','retail','payg',0::numeric,'planned','robot-cafe',jsonb_build_object('guest_visible',true)),
    ('massage-pavilion','Massage / Wellness Pavilion','wellness','paid',0::numeric,'planned','massage-pavilion',jsonb_build_object('guest_visible',true,'pricing_to_confirm',true))
),
upsert_facilities as (
  insert into public.facilities (
    organisation_id, property_id, code, name, facility_type, access_mode, price, currency,
    map_node_id, status, metadata
  )
  select
    p.organisation_id, p.id, f.code, f.name, f.facility_type, f.access_mode, f.price, 'NZD',
    f.map_node_id, f.status, f.metadata
  from jacksons_property p
  cross join facility_seed f
  on conflict (property_id, code) do update set
    name = excluded.name,
    facility_type = excluded.facility_type,
    access_mode = excluded.access_mode,
    price = excluded.price,
    status = excluded.status,
    metadata = public.facilities.metadata || excluded.metadata,
    updated_at = now()
  returning id
),
node_seed(code,label,node_type,status,description,metadata) as (
  values
    ('entry','Entry','access_point','active','Main guest vehicle entry',jsonb_build_object('position_required',true)),
    ('exit','Exit','access_point','active','Main guest vehicle exit',jsonb_build_object('position_required',true)),
    ('office-checkin','Office / Check-in','building','active','Guest support and current check-in point',jsonb_build_object('position_required',true)),
    ('services-building','Services Building','building','active','Kitchen, lounge, toilets, showers and laundry area',jsonb_build_object('position_required',true)),
    ('kitchen-lounge','Kitchen & Lounge','facility','active',null,jsonb_build_object('position_required',true)),
    ('toilets-showers','Toilets & Showers','facility','active',null,jsonb_build_object('position_required',true)),
    ('laundry','Laundry','facility','active',null,jsonb_build_object('position_required',true)),
    ('sauna','Wood Barrel Sauna','facility','active',null,jsonb_build_object('position_required',true)),
    ('hot-tubs','Hot Tubs','facility','active',null,jsonb_build_object('position_required',true)),
    ('dump-station','Camper Dump Station','rv_service','active','Departure service point for campers',jsonb_build_object('position_required',true)),
    ('glow-worm-1','Glow Worm Viewing Area 1','attraction','active',null,jsonb_build_object('position_required',true)),
    ('glow-worm-2','Glow Worm Viewing Area 2','attraction','active',null,jsonb_build_object('position_required',true)),
    ('waterfall-walk','Waterfall Walk','track','active','Approx. 20 minute walk',jsonb_build_object('position_required',true,'approx_walk_minutes',20)),
    ('quartz-mine-walk','Old Quartz Mine Walk','track','active','Approx. 45 minute walk',jsonb_build_object('position_required',true,'approx_walk_minutes',45)),
    ('entry-gate','Future ANPR Entry Gate','planned_device','planned',null,jsonb_build_object('position_required',true)),
    ('exit-gate','Future ANPR Exit Gate','planned_device','planned',null,jsonb_build_object('position_required',true)),
    ('self-checkin-kiosk','Future Self Check-in Kiosk','planned_device','planned',null,jsonb_build_object('position_required',true)),
    ('ev-charging','Future EV Charging','planned_facility','planned',null,jsonb_build_object('position_required',true)),
    ('vending-hub','Future Vending Hub','planned_facility','planned',null,jsonb_build_object('position_required',true)),
    ('robot-cafe','Future Robot Cafe','planned_facility','planned',null,jsonb_build_object('position_required',true)),
    ('massage-pavilion','Future Massage / Wellness Pavilion','planned_facility','planned',null,jsonb_build_object('position_required',true))
),
upsert_nodes as (
  insert into public.map_nodes (
    organisation_id, property_id, code, label, node_type, status, guest_visible, description, metadata
  )
  select
    p.organisation_id, p.id, n.code, n.label, n.node_type, n.status, true, n.description, n.metadata
  from jacksons_property p
  cross join node_seed n
  on conflict (property_id, code) do update set
    label = excluded.label,
    node_type = excluded.node_type,
    status = excluded.status,
    description = excluded.description,
    metadata = public.map_nodes.metadata || excluded.metadata,
    updated_at = now()
  returning id
),
integration_seed(provider,category,status,capabilities,config_public,metadata) as (
  values
    ('Supabase','backend','connected',
      jsonb_build_array('database','storage','rest'),
      jsonb_build_object('project_ref','ckqakprgjcukfgvkszrk'),
      jsonb_build_object('connection_layer','base44_connector')),
    ('GitHub','source_control','connected',
      jsonb_build_array('repo','issues','pull_requests'),
      jsonb_build_object('repository','nextlevelnz/fastkiwi'),
      jsonb_build_object('connection_layer','chatgpt_and_base44')),
    ('Miro','planning','connected',
      jsonb_build_array('boards','write'),
      jsonb_build_object('master_board','FASTKIWI MASTER OPERATING MAP'),
      jsonb_build_object('connection_layer','chatgpt_and_base44')),
    ('Gmail','communications','connected',
      jsonb_build_array('send','read'),
      jsonb_build_object(),
      jsonb_build_object('connection_layer','base44_connector')),
    ('Google Drive','files','connected',
      jsonb_build_array('drive'),
      jsonb_build_object(),
      jsonb_build_object('connection_layer','base44_connector')),
    ('HubSpot','crm','connected',
      jsonb_build_array('oauth'),
      jsonb_build_object(),
      jsonb_build_object('connection_layer','base44_connector')),
    ('SmartBooking','pms','not_configured',
      jsonb_build_array('reservations','availability','guest_sync'),
      jsonb_build_object(),
      jsonb_build_object('requires_api_verification',true)),
    ('Channex','channel_manager','not_configured',
      jsonb_build_array('channels','availability','rates'),
      jsonb_build_object(),
      jsonb_build_object('requires_api_verification',true)),
    ('Payment / EFTPOS','payments','not_configured',
      jsonb_build_array('payments','refunds','unattended'),
      jsonb_build_object(),
      jsonb_build_object('supplier_selection_required',true)),
    ('ANPR / Gate','access','not_configured',
      jsonb_build_array('plate_authorization','entry','exit'),
      jsonb_build_object(),
      jsonb_build_object('supplier_selection_required',true)),
    ('Smart Access','access','not_configured',
      jsonb_build_array('qr','pin','locks'),
      jsonb_build_object(),
      jsonb_build_object('supplier_selection_required',true))
)
insert into public.integration_connections (
  organisation_id, property_id, provider, category, connection_mode, status, capabilities, config_public, metadata
)
select
  p.organisation_id, p.id, i.provider, i.category, 'adapter', i.status, i.capabilities, i.config_public, i.metadata
from jacksons_property p
cross join integration_seed i
on conflict (organisation_id, property_id, provider) do update set
  category = excluded.category,
  status = excluded.status,
  capabilities = excluded.capabilities,
  config_public = excluded.config_public,
  metadata = public.integration_connections.metadata || excluded.metadata,
  updated_at = now();
