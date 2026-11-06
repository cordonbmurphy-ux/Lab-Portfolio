# IAM Lab 6: Active Directory Mover, Department Transfer Access Transition

Built 2026-11-06 from the department-transfer exercise posted by Cyber and Chill (@cyberandchill) the same day: create two departments with different access, move an employee from one to the other, and work out what they should lose and what they should gain. Runs on the Lab 5 directory (fictional Meridian Health, `meridianlab.local`), so the mover is a real account in an existing model, not a fresh toy example. Total cost: $0.

## Status, stated plainly

- **Completed by Merlin (2026-11-06):** the full lab package. Transfer model in `data/` (mover, group-to-entitlement mapping, expected lose/gain), three ready-to-run PowerShell scripts in `scripts/`, and a model validation harness that was actually executed: **8 of 8 checks passed** (log in `validation/validation-log.txt`).
- **Runs on Cordon's machine:** the live execution, inside the Lab 5 Windows Server VM (LAB-DC01) after the Lab 5 build creates the directory. The three scripts run in order and take minutes.
- **Honesty label:** lab environment only. This is not employer experience with Active Directory movers, and it is written that way everywhere it appears.

## Business problem

Joiners get checklists and leavers get urgency; movers get forgotten. An internal transfer processed as "add the new access, we'll clean up later" leaves the employee holding both departments' entitlements: privilege accumulation, an audit finding, and sometimes a segregation-of-duties conflict. This lab performs the transfer the way an IAM analyst should, removal and addition in one change, and proves the end state instead of assuming it.

## The scenario

Megan Doyle (`mdoyle`), Revenue Cycle Manager, transfers to Clinical as Clinical Operations Supervisor.

| | Before (Revenue Cycle) | After (Clinical) |
|---|---|---|
| OU | OU=Revenue Cycle, People | OU=Clinical, People |
| Groups | GG_Revenue_Users, GG_VPN_Access | GG_Clinical_Users |
| Title | Revenue Cycle Manager | Clinical Operations Supervisor |

**What she loses** (all four entitlements, none negotiable):
- Revenue Cycle shared drive (read/write), via GG_Revenue_Users
- Billing system: biller workqueue, via GG_Revenue_Users
- Claims status tool: submitter role, via GG_Revenue_Users
- VPN remote access, via GG_VPN_Access. Per-person grant, removed on role change under the Lab 5 directory rule; the Clinical role re-justifies it if it is actually needed. Silently keeping it is how remote access outlives the job that needed it.

**What she gains** (via GG_Clinical_Users):
- Clinical shared drive (read/write)
- EHR lab tenant: clinical viewer
- Clinic schedule board (edit)

**What she keeps:** the account itself. Same account and SID, same email, same MFA enrollment, account stays enabled. A move changes entitlements, never identity; deleting and recreating the account would be a joiner and a leaver stapled together, with a new SID and broken ownership history.

## Execution steps (live build, on LAB-DC01)

1. **Snapshot:** run `scripts/01-Show-CurrentAccess.ps1`. It prints the account properties and group memberships and keeps a transcript. This is the before evidence.
2. **Dry run:** `scripts/02-Move-Department.ps1 -WhatIf`. Confirm the removals listed are exactly the from-groups and the addition is the to-group.
3. **Move:** run `scripts/02-Move-Department.ps1`. It safety-checks the target OU and groups first, removes before it adds (the account never holds both departments at once), moves the object, and updates Department and Title. It refuses to run against an account the model does not describe.
4. **Verify:** run `scripts/03-Verify-Transition.ps1`. Five live checks (V-01 to V-05 in the script): target OU, Department and Title updated, no residual old-department groups, all target groups present, account still enabled. It throws if any check fails, and prints the lose/gain summary for the change ticket.

## The defect this lab catches

The add-only move: add GG_Clinical_Users, forget the removals. The model validator reproduces it (check T-07): the mover ends up holding all four entitlements she should have lost, including the biller workqueue at the same time as a clinical viewer role, a segregation-of-duties conflict an access review would flag. The verify script's V-03 check exists because this mistake is the norm, not the exception.

## Validation test cases for the live build

| ID | Case | Expected | Maps to |
|---|---|---|---|
| MV-01 | Before snapshot transcript reviewed | Shows Revenue Cycle OU, GG_Revenue_Users, GG_VPN_Access | T-02 |
| MV-02 | Dry run with -WhatIf | Lists 2 removals and 1 addition, changes nothing | T-04 |
| MV-03 | After the move, mdoyle opens the Revenue Cycle share | Access denied | T-05 |
| MV-04 | After the move, mdoyle opens the Clinical share | Read/write works | T-03 |
| MV-05 | VPN sign-in attempt as mdoyle after the move | Denied; VPN was removed pending re-justification | T-04 |
| MV-06 | Verify script run | V-01 to V-05 all PASS, lose/gain summary printed | T-04, T-05, T-08 |
| MV-07 | Deliberate fault: re-add GG_Revenue_Users, rerun verify | V-03 FAILs and the script throws | T-07 |
| MV-08 | Account properties after the move | Same account, enabled, email and MFA enrollment untouched | T-08 |

Record actual results as you run it, including anything that breaks and the fix.

## Evidence checklist (what to capture)

- The 01 before-snapshot transcript and a fresh snapshot after the move (the diff is the lab's core artifact).
- The 02 move transcript, including the -WhatIf dry run output.
- The 03 verify output with V-01 to V-05 passing.
- The filled validation table above.

## What this proves, in interview language

"I ran a department transfer as a controlled access transition: snapshotted the mover's entitlements first, removed the old department's groups and a per-person VPN grant in the same change as adding the new department's access, moved the object and updated the HR attributes, then verified zero residual access. The add-only version of that move leaves privilege accumulation and a segregation-of-duties conflict, and my verification step is built to catch exactly that." Every clause maps to a script or a validation check in this package.

## Files in this package

- `data/mover-model.json`: mover, group-to-entitlement mapping, expected lose/gain/keep, policy notes.
- `data/access-transition-matrix.csv`: the human-readable transition table, checked against the model by the validator.
- `scripts/01` to `03`: before snapshot, the move, live verification.
- `validation/validate_model.py` and `validation-log.txt`: the model checks, 8 of 8 passed on 2026-11-06.
