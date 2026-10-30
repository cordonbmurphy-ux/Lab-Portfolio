# Business Analyst Labs
Author: Cordon Murphy, Business Analyst and QA Analyst
Grounding: Recreated from real BA work at CVS Health/Aetna and Flagstar Bank. At CVS Health/Aetna the split was about 80 percent business analysis and 20 percent QA and testing. No employer data in any lab.
Tools referenced: Jira, Azure DevOps, ALM Quality Center, Workday (cloud hosted example from Flagstar Bank), backlog refinement and sprint planning in Agile teams
Note on tools: No hands on Confluence claim is made in this pack, matching the confirmed record.

---

## BA Lab 1: Requirements That Can Actually Be Tested, Healthcare Release

Business problem
A healthcare release arrived with requirements written as intentions: "the system should handle duplicate submissions correctly." Nobody could test that sentence, and every reader understood it differently.

What I built
A requirements rewrite lab: took 8 vague requirements of the kind that cause release arguments and rewrote each into testable requirements with acceptance criteria, data states, and a traceability line.

Steps
1. Listed the data states each requirement actually lives in: valid, duplicate, late, reversed, effective dated in the past, effective dated in the future, terminated yesterday.
2. Rewrote each requirement in one sentence with an actor, a condition, and an observable result. Removed every "should handle correctly" type phrase.
3. Wrote acceptance criteria in Given, When, Then form for the happy path and for the two highest risk negative paths.
4. Attached the regulatory or business reason to each requirement, so priority arguments have something to stand on.
5. Built the traceability matrix: requirement to acceptance criteria to test case ID to defect if one was found.
6. Ran the tester check on my own BA work: a tester who has never seen the feature must be able to write a case from the requirement alone, without messaging me.

Example from the lab
Before: "The system should handle duplicate claims correctly."
After: "When a claim with the same member, provider, date of service, and procedure code arrives within 30 days of a paid claim, the system holds the second claim as a duplicate, shows the first claim number to the reviewer, and does not pay it until a reviewer releases or denies it."
Criteria cover: exact duplicate, near duplicate with a corrected code, duplicate arriving after a reversal.

Validation
| Check | Method | Result |
|---|---|---|
| Every requirement testable by a stranger | Peer style self review, case written from text alone | 8 of 8 passed after rewrite, 2 of 8 before |
| Every requirement has data states named | Matrix review | 8 of 8 |
| Every criterion maps to a test case | Traceability matrix | 24 criteria, 24 cases |

Deliverables in this lab
- 8 before and after requirements
- Traceability matrix sample
- Acceptance criteria set, 24 items

What this proves
Requirements work that ends arguments instead of starting them, from real healthcare BA practice.

---

## BA Lab 2: Backlog Refinement and Sprint Planning, Making Work Ready

Business problem
A sprint kept starting with stories nobody could estimate. Halfway through, testing found the real requirement hidden in a comment, and the sprint goal was gone.

What I built
A refinement lab recreated from Agile BA work at CVS Health/Aetna and Flagstar Bank: a backlog of 12 raw stories taken through refinement to ready, with the definition of ready applied honestly.

Steps
1. Scored each story against ready criteria: clear user and value, acceptance criteria present, data states named, dependencies identified, test data path known, no hidden regulatory question.
2. Split 3 stories that were really 2 or 3 pieces of work wearing one title. Splitting followed the data state line, not the screen line.
3. Sent 4 stories back with specific questions instead of vague ones. Each question named the decision, the owner, and what changes if the answer flips.
4. Estimated the ready stories using surface area, not story count: requirements weighted, integrations counted, regression surface named, environment and data effort as its own line.
5. Built the sprint plan with assumptions written next to the numbers, so the plan can be negotiated instead of just missed.

Validation
| Check | Result |
|---|---|
| Stories ready at sprint start | 8 of 12, 4 held back with named blockers |
| Stories split before estimation | 3 split into 7 |
| Mid sprint requirement surprises in this model | Zero, because the 4 unready stories never entered |

Finding
Holding a story out of a sprint is BA work, not BA failure. The lab documents the 4 held stories and what unblocked each, because that record is what makes the next refinement faster.

Deliverables in this lab
- Definition of ready checklist
- Refined backlog, 12 stories scored
- Sprint plan with assumptions attached

What this proves
Agile BA practice that protects a sprint: refinement, splitting, estimation by surface area, and the discipline to say not ready.

---

## BA Lab 3: Current State to Future State Workflow Analysis, Bank Operations

Business problem
A bank operations team re typed the same customer data into two systems and then reconciled the differences by hand every Friday. Everyone knew it was waste. Nobody had mapped it, so nobody could fix it.

What I built
A workflow analysis lab in the same method I used for the EMR clinic check in analysis, applied to a banking operations workflow recreated from Flagstar Bank BA experience.

Steps
1. Mapped the current state step by step with time and owner on each step: where data entered, where it was re typed, where it waited, where errors were found.
2. Counted the failure points: 2 re entry points produced most Friday reconciliation items. Named the data states that broke: corrected effective dates and duplicate submissions.
3. Presented two future state options with honest tradeoffs. Option A, single entry with an interface to the second system. Option B, keep two systems, add a validation report before Friday so errors surface daily.
4. Recommended Option A, and wrote why Option B was still documented: if the interface project slipped, the team still needed a working improvement, not a stalled one.
5. Defined success measures at 30, 60, and 90 days: reconciliation items per week, re entry steps eliminated, error rate on corrected records.
6. Wrote the requirements for the recommended option in testable form, reusing the BA Lab 1 method, so analysis and requirements connect.

Validation
| Measure | Current state baseline in lab | Future state target |
|---|---|---|
| Manual re entry points | 2 | 0 |
| Reconciliation items per week | Modeled at 40 plus | Under 10 |
| Time to find a data error | Up to 5 days, Friday batch | Same day |

Deliverables in this lab
- Current state and future state maps
- Options paper with recommendation and fallback
- Success measures and the requirements that follow from them

What this proves
A BA who maps before recommending, quantifies the pain, and leaves the client a fallback instead of a single fragile plan.

---

## BA Lab 4: UAT Planning and the Go or No Go Call

Business problem
A release was technically tested and still not ready for users. Business users had never run their real workflows on the final build, and the release meeting had a pass rate but no judgment.

What I built
A UAT lab: plan, scripts built from real user workflows, defect triage by impact, and a written go or no go recommendation.

Steps
1. Built UAT scripts from user workflows, not from system menus: the 6 workflows users do daily, in the order they do them, with their real data states.
2. Recruited the right testers on paper: one power user, one new hire, one user who handles exceptions. Each finds a different class of problem.
3. Set UAT entry criteria: system testing signed off, known defects listed with workarounds, test data loaded with the states users actually see, including duplicates and reversals.
4. Ran triage on the lab defect set by what each defect does, not by count: 2 data corrupting defects outweigh 40 cosmetic ones, and the room hears them in business language.
5. Wrote the go or no go position on four legs: open defects by impact, untested surface declared out loud, data states that never ran, rollback position for the first hour if production fails.
6. Recorded a no go in this lab, with the exact evidence and what would change the call. A yes that was never at risk of being a no is worth nothing.

Validation
| Leg | Lab position |
|---|---|
| Open defects by impact | 1 severity 1 data defect open, blocks go |
| Untested surface | Future dated records never ran on final build, declared |
| Data states | Duplicate and reversal ran, future dated did not |
| Rollback | Walked through, owners named |

Deliverables in this lab
- UAT plan with entry and exit criteria
- 6 workflow based UAT scripts
- Go or no go memo with evidence

What this proves
BA and QA judgment in one deliverable: planning user acceptance, triaging by impact, and giving a release room a decision it can sign.

For freelance buyers
This lab set is the service: requirements cleanup, backlog refinement, workflow analysis, and UAT planning, delivered as documents your team can use the same week. Async, text based delivery. No calls required to get value from any of it.
