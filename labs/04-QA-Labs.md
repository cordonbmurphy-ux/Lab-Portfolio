# QA Labs
Author: Cordon Murphy, QA Analyst, 9+ years testing, CompTIA Security+
Grounding: Recreated from real QA work at CVS Health/Aetna, Flagstar Bank, and Truist, plus Workday testing at Flagstar and MGM Grand Detroit support experience. No employer data.
Tools referenced: Postman, SoapUI, ALM Quality Center, Jira, Azure DevOps, ChatGPT, Claude, and Microsoft Copilot used in QA work
Language rule followed: this pack says testing. It does not sell automation it does not claim. No heavy automation, no heavy SQL claim.

---

## QA Lab 1: Test Planning by Data States, Healthcare Claims Workflow

Business problem
Two test cycles on the same build produced opposite conclusions. One team said ready, one said broken. The code was the same. The data was different, and nobody had listed the data states before testing started.

What I built
A test plan lab for a healthcare claims workflow where coverage is defined by data states, not by screen count.

Steps
1. Listed every state the claim data can be in: valid, duplicate, late, reversed, corrected, effective dated in the past, effective dated in the future, member terminated yesterday, provider out of network.
2. Mapped each state to the business promise made about it, which turned each state into a test.
3. Wrote the plan: scope, entry criteria (requirements testable, data built, environment stable), exit criteria (all high risk states executed, no severity 1 or 2 open, untested states declared).
4. Built the traceability matrix: requirement to data state to test case to result.
5. Wrote 18 cases for the highest risk states first: duplicate, reversal after payment, future dated correction.
6. Ran the estimation method I actually use: count surface area, requirements weighted, integrations, regression surface, data build effort as its own line, assumptions stated with the number.

Validation
| ID | Case | Expected | Type |
|---|---|---|---|
| QA1-01 | Duplicate claim within window | Held, first claim shown, no double pay | Pass model |
| QA1-02 | Reversal after payment | Payment recovered, history retained, no deletion | Pass model |
| QA1-03 | Future dated correction | Held until effective date, not applied early | Pass model |
| QA1-04 | Terminated member, service before termination | Pays by service date rules, not by termination alone | Pass model |

Finding
A traceability matrix that maps cases to requirements but never names data states looks complete and is not. This lab shows the corrected matrix, with the states as their own column, so a reviewer can see the gap in ten seconds.

Deliverables in this lab
- Test plan with entry and exit criteria
- Data state inventory, 9 states
- Traceability matrix with data state column
- Estimate with assumptions

What this proves
Senior level test planning: coverage argued from data and risk, not from case counts.

---

## QA Lab 2: API Testing in Two Layers, Contract Is the Floor, Behavior Is the Work

Business problem
An API passed every contract check and was still wrong in production. The status code was right and the amount was wrong. The field was present and carried the previous member value.

What I built
A two layer API testing lab using Postman, with SoapUI equivalents noted, recreated from healthcare API validation work at CVS Health.

Steps
1. Layer 1, contract: validated structure, types, required fields, status codes, and documented error shapes against the API definition. Built a Postman collection with one request per endpoint and environment variables for base URL and auth, no secrets stored in the collection.
2. Layer 2, behavior: tested the business rule behind each endpoint. Does the endpoint enforce the rule, or trust the caller to. Does it return the same answer twice. What happens with a valid request for a record in the wrong state, a duplicate submission, a date outside the plan year.
3. Tested error behavior as its own surface: error shape, error message content, and whether an error response ever exposed data from another record. That last one is a finding, not a bug.
4. Tested idempotency on the duplicate submission: second identical request must not create a second effect.
5. Documented results as a summary a BA or developer can act on: endpoint, case, expected, actual, evidence from response body and status.

Validation
| ID | Case | Layer | Expected |
|---|---|---|---|
| API-01 | Valid request, happy path | Contract and behavior | 200, correct values, not just correct shape |
| API-02 | Missing required field | Contract | 400 with documented error shape, no stack detail exposed |
| API-03 | Record in wrong state | Behavior | Rule enforced by endpoint, clear error |
| API-04 | Duplicate submission | Behavior | No second effect, duplicate handled as designed |
| API-05 | Date outside plan year | Behavior | Rejected by rule, not by crash |
| API-06 | Cross record data in error | Security behavior | Error contains no other record data |

Finding recreated in this lab
The contract suite was fully green while 2 behavior cases failed. That is the point of the lab, stated on the summary itself: a green contract suite means the API is eligible to be tested. Nothing more.

Deliverables in this lab
- Postman collection structure, described request by request
- 16 API test cases across both layers
- API test summary report sample

What this proves
API testing with Postman and SoapUI that finds the defects contract testing misses, in healthcare and any API driven system.

---

## QA Lab 3: Section 508 Accessibility Testing, Keyboard Only for an Afternoon

Business problem
An application passed its automated accessibility checker and still could not be used with a keyboard. A screen reader user hit an error they never received, because the error was only a red border.

What I built
An accessibility testing lab recreated from Section 508 work at CVS Health, Flagstar Bank, and Truist. Automated checks are the start in this method, not the finish.

Steps
1. Ran the automated checker first and recorded its results as the baseline, not the verdict.
2. Unplugged the mouse for the full workflow pass: reached every control by keyboard, tracked visible focus on every step, noted where focus landed after an error and after a dialog closed.
3. Tested error identification properly: every error must be text, must name the field, must be reachable by a screen reader, and must not be color alone.
4. Tested form labels and alt text by meaning, not presence: a checker confirms alt text exists, this lab confirms it does not say image123 and actually describes the image purpose.
5. Tested headings and order: focus order and reading order follow the visual task order, not the code order by accident.
6. Wrote findings the way a developer needs them: component, criterion in plain language, steps with keyboard only, expected vs actual, and a small fix suggestion for each.

Validation
| Check | Automated checker | This lab method |
|---|---|---|
| Alt text present | Pass | Fail on meaning, alt was a file name |
| Focus visible | Not checked | Fail, focus lost after error |
| Error in text form | Not checked | Fail, color only error found |
| Keyboard completion of full task | Not checked | Blocked at step 4 before fix, passed after |

Finding
Every serious finding in this lab was invisible to the checker. That is not an argument against checkers. It is the reason the keyboard pass exists, and why accessibility testing belongs to testers, not only to tools.

Note: No DHS Trusted Tester Certification is claimed. This lab stands on confirmed Section 508 testing experience at three employers.

Deliverables in this lab
- Accessibility test checklist, keyboard, focus, errors, labels, order
- Findings report with criterion, steps, and fix suggestion per item
- Before and after retest log

What this proves
Section 508 testing that protects real users and gives developers fixes they can make the same day.

---

## QA Lab 4: Defect Reporting and Regression, The Report Is the Product

Business problem
A queue of defects nobody could reproduce sat aging while everyone quietly agreed they were probably not real. Releases slipped, not from the defects, but from the arguments about them.

What I built
A defect and regression lab: 5 defect reports written to a standard, a regression selection method, and a retest log.

Steps
1. Wrote each defect to the standard I use everywhere: title stating behavior and condition, steps carrying the data state (which record, which effective date, which role was signed in), expected and actual side by side in plain language with the requirement ID attached, impact line last because it decides priority better than a severity dropdown.
2. Applied the five minute test: a developer who has never seen the feature should reproduce the failure in under five minutes without messaging me. If they have to ask, the report was not finished.
3. Included one defect that was really a requirements gap, and showed how it was reclassified honestly instead of forced through as a code bug.
4. Built regression selection by risk, not by habit: every case touching changed data states, every case at an integration seam, every case that failed on this feature before, plus a thin happy path pass over the untouched surface.
5. Retested fixes with the original data state first, then with the neighboring states, because a fix that works on the reported record and breaks its neighbor is not a fix.

Validation
| Standard | Check |
|---|---|
| Reproducible without questions | 5 of 5 reports pass the five minute test in this lab |
| Requirement attached | 5 of 5, 1 reclassified as requirement gap |
| Regression chosen by risk | Changed states, seams, prior failures, thin happy path |
| Retest covers neighbors | Original state plus 2 neighboring states per fix |

Deliverables in this lab
- 5 sample defect reports, full format
- Regression selection worksheet
- Retest and regression log sample in ALM Quality Center style

What this proves
The writing and judgment work behind QA: defects that get fixed, regression that fits the time it is given, and honest classification when the problem is not code.

For freelance buyers
These labs are the QA service in miniature: test plan, API testing, accessibility pass, or defect and regression cleanup, delivered as reports your developer can work from directly. Async and text based, no meeting required to start.
