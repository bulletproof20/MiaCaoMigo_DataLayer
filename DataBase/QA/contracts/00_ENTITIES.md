# QA entity catalog

Guaranteed entities after `stages/fixtures.ps1` (not bulk datasets).

## QA_CLIENT_ACTIVE

| | |
|--|--|
| Key | `goncalo.pratas.cstress@gmail.com` |
| Fixture | `fixtures/seed/m1_core_context.sql` |
| Lookup | `qa_client_active_id()` |
| Use | Mod2 adoption owner, Mod4 scheduling |

## QA_CLIENT_SECONDARY

| | |
|--|--|
| Key | `goncalo.machado.cstress@gmail.com` |
| Lookup | `qa_client_secondary_id()` |
| Use | Mod4 client/animal mismatch |

## QA_REGISTRAR

| | |
|--|--|
| Key | `employee.ema_emp = 20@miacaomigo.pt` |
| Lookup | `qa_registrar_emp_id()` |
| Use | ownership, login test 03 |

## QA_VET_PRIMARY

| | |
|--|--|
| Key | `OMV-QA-PRIMARY` |
| Lookup | `qa_vet_primary_id()` |
| Expert | medicina interna + medicina felina |

## QA_EMP_CLOCKABLE

| | |
|--|--|
| Key | `qa.clockable@miacaomigo.pt` + open `clock_in` |
| Lookup | `qa_emp_clockable_id()` |

## QA_EMP_ABSENCE_OVERLAP

| | |
|--|--|
| Key | `21@miacaomigo.pt` + pending absence +15d |
| Lookup | `qa_emp_absence_overlap_id()` |

## QA_ANIMAL_*

| Entity | `reg_id_ani` | State | Role |
|--------|--------------|-------|------|
| Internal | QA-ANI-001 | Interno | welfare delivery + ownership lifecycle |
| No delivery | QA-ANI-002 | Interno | concession / delivery-date integrity |
| Adopted | QA-ANI-003 | Adotado | Mod4 scheduling / overlap |
| Shelter delivery | QA-ANI-004 | Interno | shelter intake delivery |
| Stress internal | QA-ANI-005 | Interno | concurrent adoption stress |

Fixture: `fixtures/seed/m2_animals_ownership.sql`

Lookups: `qa_animal_internal_id()`, `qa_animal_no_delivery_id()`, `qa_animal_adopted_id()`, `qa_animal_delivery_shelter_id()`, `qa_animal_stress_internal_id()`

## QA_EXTERNAL_SHELTER

| | |
|--|--|
| Key | `shelter@qa.miacaomigo.pt` |
| Lookup | `qa_external_entity_shelter_id()` |
| Use | Mod2 delivery integrity |

## QA_LOGIN_SESSION_EMP

| | |
|--|--|
| Key | `12@miacaomigo.pt` (open session in fixture) |
| Lookup | `qa_login_session_emp_email()` |

## QA_PRODUCT_STOCK

| | |
|--|--|
| Key | `ref_pro = QA-PRO-001` |
| Fixture | `fixtures/seed/m3_commercial_product.sql` |
| Lookup | `qa_product_int_p001_id()` |

## QA_PRODUCT_STRESS

| | |
|--|--|
| Key | `ref_pro = STRESS-M3` |
| Fixture | `fixtures/seed/m3_stress_commercial.sql` |
| Lookup | `qa_stress_product_id()` |

## Time slots (Mod4)

| Contract | Value |
|----------|--------|
| Overlap | `2099-06-15 10:00` |
| Notification | `2099-07-11` |
