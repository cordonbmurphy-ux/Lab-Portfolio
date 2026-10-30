# EMR Labs
Author: Cordon Murphy, EMR analyst training (Athena/Centricity)
Label for every lab: Training simulation. Simulated environment. Not a real employer system and not production Epic or Cerner build experience.
Tools referenced: Athena Flow V23 style ambulatory EMR, flags and documents workflow, DrFirst and EPCS concepts, ServiceNow style ticketing, ALM Quality Center style test documentation

---

## EMR Lab 1: Flag to Document Lifecycle, Closing the Unsigned Document Pile

Business problem
A 3 provider clinic ends every week with unsigned documents sitting on desktops with no owner. Phone notes get created from flags and then forgotten. Nothing can bill, nothing can be audited, and the provider cannot tell what is still open.

What I built
A full lifecycle simulation in a training chart: created flags at all three priorities, routed one to a group, converted flags to documents, worked each document through its statuses, and cleared the desktop.

Steps
1. Created 6 flags: 2 urgent, 2 important, 2 normal. Each flag carried a clear action line, no PHI style detail beyond what a flag should hold, and a named recipient.
2. Viewed the same flags in all five views to confirm priority sorting and group routing worked the same in each view.
3. Routed one urgent flag to a group using group search, the way front desk routes a refill request that any MA can pick up.
4. Converted 3 flags to documents: 1 phone note, 1 office note, 1 Rx refill request. Confirmed each conversion created exactly one document, status On Hold.
5. Worked the documents: appended clinical detail, moved On Hold to In Progress, then Signed. Confirmed signed documents left the desktop.
6. Left 1 document unsigned on purpose, then ran the end of day check to prove the desktop report catches it.
7. Tested flag expiry: set a flag near its 30 day removal point and confirmed retrieval behavior after removal.

Validation
| ID | Case | Expected | Result |
|---|---|---|---|
| FL-01 | Urgent flag sorts first in every view | Urgent at top, normal at bottom | Pass |
| FL-02 | Flag converted to phone note | Exactly 1 document, On Hold | Pass |
| FL-03 | Signed document clears desktop | Document leaves desktop after sign | Pass |
| FL-04 | Unsigned document is caught | End of day list shows the 1 unsigned item with owner | Pass |
| FL-05 | Flag at 30 days | Flag removes, audit trail retains the action | Pass |

Finding
Converting a flag created the document but did not carry the priority into the document view. A normal priority phone note and an urgent phone note look identical once converted. My recommendation in the lab notes: the converter writes the priority into the first line of the phone note until the system carries it natively. That one line is the difference between a refill that waits a week and one that does not.

Deliverables in this lab
- 10 test cases with expected and actual
- Document lifecycle state diagram: On Hold, In Progress, Signed, Removed
- End of day desktop clearing checklist

What this proves
I can run the daily clinical communication workflow in an EMR, test it by states instead of screens, and spot where a workflow loses information at a handoff.

---

## EMR Lab 2: User Setup and Role Based Privileges, Roles Drive Privileges

Business problem
A clinic hires a provider, a nurse, and a front desk staffer in the same week. If roles are wrong, the front desk user can sign documents they should never touch, or the provider cannot prescribe because a credential field was left blank.

What I built
Three complete user setups in the simulated EMR, with credentials, activation dates, and role assignments, then a full privilege test matrix against those roles.

Steps
1. Created the provider user: name, user ID in first.last format, location, NPI, DEA, license number, credentialed dates, activation date set to training day.
2. Created the nurse user: role limited to clinical support actions, no prescribing, no document signing as provider.
3. Created the front desk user: scheduling and flag creation only, no clinical documentation, no prescribing.
4. Set an expiration date on a test user and confirmed what happens at expiry: login blocked, existing documents keep their author history.
5. Ran the privilege matrix: each user attempted 12 actions, from opening a chart to signing a note to prescribing.
6. Deliberately assigned the nurse the provider role, documented exactly what broke in control terms, then corrected it and retested.

Validation
| ID | Case | Expected | Result |
|---|---|---|---|
| US-01 | Front desk attempts to sign a note | Blocked, no sign option shown | Pass |
| US-02 | Provider prescribes with valid NPI and DEA | Prescription proceeds to EPCS step | Pass |
| US-03 | Provider with missing DEA attempts controlled prescription | Blocked with credential message | Pass |
| US-04 | Expired user attempts login | Blocked on expiration date | Pass |
| US-05 | Nurse with wrong role signs as provider | Should be blocked. Was allowed. Defect logged | Fail, defect US-D1 |

Finding, defect US-D1, severity high in a real clinic
Role assignment alone changed signing rights with no second check on credentials. The lab recommendation: signing requires both the role and a credential flag, so a single setup error cannot create a signing user. I wrote the defect with steps, data state, expected vs actual, and impact, the same format I use in banking and healthcare QA.

Deliverables in this lab
- 3 user setup records with every required field named
- 36 cell privilege test matrix, 12 actions by 3 roles
- Defect report US-D1 with reproduction steps

What this proves
I understand provisioning in a clinical system, least privilege, and why user setup is a patient safety control, not paperwork.

---

## EMR Lab 3: Monthly KB Update Test Cycle, The Allergy List Step That Prevents Harm

Business problem
Every month the knowledge base updates: medications are removed, codes are added, fixes ship. If a removed medication is not added to the allergy custom list first, a provider can prescribe it with no warning.

What I built
A complete KB update test plan and execution for a simulated October cycle, building on my existing KB Update Test Plan portfolio piece and extending it with regression and downtime checks.

Steps
1. Read the mock release notes: 2 removed medications, 2 new COVID vaccine codes, 1 fix for duplicate phone notes on flag conversion.
2. Completed the pre update safety step first: added both removed medications to the allergy custom list before the update was applied.
3. Wrote the test plan: scope, entry criteria (release notes reviewed, allergy list updated, test patients ready), exit criteria (all blocking cases pass, no severity 1 or 2 open).
4. Executed 10 cases: prescribing both removed meds, searching both new codes, flag conversion duplication check, regression on active prescriptions for non removed meds.
5. Ran a negative test: removed one medication from the allergy list in the test environment and confirmed the warning disappeared, proving the safety step is the control.
6. Logged 1 low defect: new vaccine code description truncated in list view.

Validation
| ID | Case | Expected | Result |
|---|---|---|---|
| KB-01 | Prescribe removed Med A 10mg | Allergy warning appears, order flagged | Pass |
| KB-02 | Prescribe removed Med B 25mg | Allergy warning appears | Pass |
| KB-03 | New vaccine codes selectable | Both codes in immunization list | Pass, low defect on display text |
| KB-04 | Flag conversion after fix | Exactly 1 phone note, no duplicate | Pass |
| KB-05 | Active non removed prescriptions | No false warnings | Pass |
| KB-06 | Allergy list entry removed in test env | Warning stops, proving control dependency | Pass, as designed |

Deliverables in this lab
- Full test plan with entry and exit criteria
- 10 executed cases with results
- Sign off recommendation: approved for production, 1 low defect logged with vendor

What this proves
This is my core QA skill applied directly to EMR analyst work: release testing, regression, safety controls, and a sign off a clinic can act on.

---

## EMR Lab 4: Go Live Sprint, Phased Implementation for a 10 Provider Clinic

Business problem
A 10 provider clinic is moving from paper to EMR. Leadership wants one go live date. The budget owner needs to know what pushing the date costs, trainers need to know who learns what, and support needs a plan for week one.

What I built
A phased go live plan, readiness checklist, workflow recommendation, and ticket triage simulation for week one.

Steps
1. Did current state vs future state analysis on check in: paper sign in and chart pull vs schedule driven chart opening, single entry vitals in the flowsheet, electronic orders, checkout from the same chart.
2. Recommended phased go live over big bang for this clinic, with reasoning: 2 departments first, lessons applied, then the rest. Named the cost of pushing the date: legacy support extension, retraining decay, and preload staleness.
3. Built the preload plan: problems, medications, allergies for every active patient, clinical list updates reviewed with providers, blue lock applied to lists under review.
4. Built the readiness checklist: build and configuration, testing sign off, training by role, super users per department, support roster, escalation path to the vendor.
5. Simulated week one tickets: 8 tickets across ServiceNow style statuses, triaged by SLA (urgent 4 hours, normal 2 business days), 1 escalated to the vendor with the full packet: steps, user role, chart state, and what was already tried.
6. Wrote the daily handoff: resolved, still open, watch items, owner for each.

Validation
| ID | Check | Expected | Result |
|---|---|---|---|
| GL-01 | Every user on readiness list has role and training logged | 100 percent before go live | Pass in simulation |
| GL-02 | Downtime procedure walked through | Paper forms staged, re entry steps clear | Pass |
| GL-03 | Ticket past SLA escalates | Urgent ticket at 4 hours escalates with packet | Pass |
| GL-04 | Unsigned documents at day 30 after go live | Target zero unsigned over 48 hours old | Tracked in handoff template |

Deliverables in this lab
- Go live plan with phased timeline
- Readiness checklist, go or no go section included
- Workflow analysis, check in, current vs future state
- Week one ticket log and handoff template

What this proves
I can plan and support an implementation, not just test screens: workflow, training, support, SLAs, and the go or no go judgment.
