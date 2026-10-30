# IAM Labs
Author: Cordon Murphy, CompTIA Security+
Grounding: Labs 1 and 2 recreate real work. Workday provisioning and deprovisioning, Flagstar Bank RBAC and SSO/MFA testing. No employer data. Labs 3 and 4 are lab environment only, built in free Entra ID and Okta developer tenants. Not prior employer experience with Entra ID, Active Directory, or Okta.
Concepts used throughout: least privilege, RBAC, joiner mover leaver lifecycle, SAML 2.0, OAuth 2.0 and OIDC concepts, SCIM provisioning concept, MFA, conditional access logic

---

## IAM Lab 1: Deprovisioning in Workday, The Access That Has to Disappear

Business problem
Provisioning gets attention because a new hire who cannot sign in is loud. Deprovisioning fails quietly. An account for someone who left in March still works in June, and nobody finds it until a review or an incident.

What I built
A joiner mover leaver test lab recreated from my Workday provisioning and deprovisioning work, written as test cases any IAM team can run.

Steps
1. Provisioned a test worker in Workday: hire event, worker ID entered, role assigned by job profile, accounts created from that hire.
2. Tested the mover case: transferred the worker to a new department and confirmed the old role permissions removed the same day the new role was added.
3. Tested the leaver case: terminated the worker with a termination date and confirmed access ended on that date, not at end of week and not when a ticket was filed.
4. Tested the rehire case: rehired the same person and confirmed the account started clean, with no resurrection of permissions from the prior employment.
5. Tested the negative cases: a terminated user attempting sign in, a transferred user attempting an action only the old role allowed, an approver attempting to approve a record they created.
6. Wrote every case with data state first: worker status, effective date, role set before and after. Most access defects are a data state nobody wrote down.

Validation
| ID | Case | Expected | Result |
|---|---|---|---|
| IAM1-01 | New hire provisions on start date | Access active on start date, not before | Pass |
| IAM1-02 | Transfer removes old role same day | Old role action blocked after transfer | Pass |
| IAM1-03 | Termination ends access on date | Sign in blocked on termination date | Pass |
| IAM1-04 | Rehire starts clean | No prior permissions restored | Pass |
| IAM1-05 | Approver approves own record | Blocked, separation of duties holds | Pass |

Finding
The mover case is where access accumulates in most systems. Addition is instant and visible. Removal is scheduled, batched, or manual, and that gap is the finding even when the test passes on day two. My lab notes flag the timing, not just the end state: test removal at hour one, not only at day end.

Deliverables in this lab
- 14 lifecycle test cases: joiner, mover, leaver, rehire
- Role before and after table for each transition
- Timing check: when removal actually takes effect vs when it should

What this proves
Real lifecycle testing from real Workday work, with the negative cases given the same rigor as the success path.

---

## IAM Lab 2: RBAC and SSO/MFA Testing at a Bank, Login Is a Business Process

Business problem
At a bank, login is not a screen. It is a control. A role that can do one action too many, or an MFA flow that fails open, becomes an audit finding with a deadline.

What I built
A test lab recreated from my Flagstar Bank work testing role based access and SSO and MFA login on banking applications.

Steps
1. Built a role matrix for 4 banking roles: what each role can view, create, approve, and administer. Wrote the cannot do column first.
2. Tested each role against the matrix, including cross role attempts: a viewer attempting an approval, an approver attempting administration.
3. Tested SSO sign in: correct credentials landing on the page the role should see, session timeout without stranding a half finished transaction, role change in the morning reflected at next sign in.
4. Tested MFA paths: successful challenge, fifth failed attempt and lockout, what the legitimate user is told and how they recover, step up challenge when risk changes mid session, remembered device behavior after a role or employment change.
5. Tested error sameness: a disabled account and a wrong password must fail the same way, without announcing which one it was.
6. Logged findings by impact in business language, not by count.

Validation
| ID | Case | Expected | Result |
|---|---|---|---|
| IAM2-01 | Viewer attempts approval | Blocked, no approve control | Pass |
| IAM2-02 | Fifth failed MFA attempt | Lockout, clear recovery path shown | Pass |
| IAM2-03 | Disabled account sign in | Same generic failure as wrong password | Pass |
| IAM2-04 | Role changed, remembered device | Device trust cleared on role change | Pass |
| IAM2-05 | Session timeout mid transaction | No half saved record, user can resume safely | Pass |

Finding
Lockout messaging is a security control and a support cost at the same time. A message that says too much helps an attacker. A message that says too little generates a support call for every legitimate lockout. The lab documents the exact wording tested and why it was accepted.

Deliverables in this lab
- Role permission matrix, 4 roles, can do and cannot do
- 18 SSO and MFA test cases including lockout and recovery
- Findings log written for an auditor to follow

What this proves
IAM testing in a regulated bank: RBAC, SSO, MFA, separation of duties, and audit ready documentation. Security+ is the cert behind it. This is the work itself.

---

## IAM Lab 3: Entra ID Lab, Users, Groups, Roles, and MFA Policy

Label: Lab environment only. Free Entra ID tenant. Built from scratch October 2026 as part of a 4 month IAM lab plan. Not prior employer experience.

Business problem
A small company has no structure in its directory: everyone is an admin, groups are named after people, and MFA is optional. Any single compromised account is a full compromise.

What I built
A clean directory structure in a lab tenant, documented like a ticket: business problem, build, validation, what broke and how I fixed it.

Steps
1. Created the lab tenant and named the structure before creating anything: departments as groups, roles separate from groups, no person named groups.
2. Created 8 lab users across 3 departments. Created security groups per department and per role.
3. Assigned roles by group, not by individual user, so a mover changes groups and inherits the right role set.
4. Enabled MFA for all users, then built the exception correctly: a break glass account, excluded from policy, with a strong password stored as a lab note and its use set to alert.
5. Configured self service password reset with two methods required, and tested the reset as a lab user, including a failed method attempt.
6. Tested as each role: signed in, attempted an admin action as a standard user, confirmed the block, confirmed the sign in log captured user, time, result, and policy applied.

Validation
| ID | Case | Expected | Result |
|---|---|---|---|
| IAM3-01 | Standard user attempts admin action | Blocked, attempt logged | Pass |
| IAM3-02 | User moved groups inherits new role | New role active at next sign in, old role gone | Pass |
| IAM3-03 | MFA required at sign in | Challenge appears for every non break glass user | Pass |
| IAM3-04 | Password reset with one method only | Reset blocked, two methods required | Pass |
| IAM3-05 | Break glass sign in | Works, alert condition noted in lab log | Pass |

What broke and how I fixed it
My first MFA policy applied to the break glass account too, which would lock the tenant if MFA service failed. I scoped the policy to exclude that one account and retested both paths. That mistake is documented on purpose. A lab that hides its mistakes proves nothing.

Deliverables in this lab
- Tenant build notes with screenshots described step by step
- Group and role design table
- Policy test log with sign in evidence

What this proves
Hands on Entra ID directory, RBAC, MFA, and SSPR build skill, learned and documented the way an IAM analyst works a ticket.

---

## IAM Lab 4: Okta Lab, App Integration with SSO and Provisioning Logic

Label: Lab environment only. Free Okta developer org. Built from scratch October 2026. Not prior employer experience.

Business problem
A team uses 6 separate passwords for 6 apps. Offboarding means 6 separate deactivations, and one is always missed. Single sign on with central lifecycle is the fix, but only if the integration is tested past the happy path.

What I built
An Okta developer org with users, groups, one SAML style app integration, sign on policy, MFA factor enrollment, and a documented joiner and leaver run.

Steps
1. Created the developer org. Created 6 users and 3 groups mapped to departments.
2. Added a test application and configured SSO: assigned the app by group, not by individual, so group membership controls access.
3. Set sign on policy: MFA required for the sensitive test app, single factor acceptable in this lab for the low risk test app, with the reasoning written down.
4. Enrolled MFA factors as a test user. Tested a sign in with a correct password and no factor, confirmed the block.
5. Ran the leaver test: deactivated one user in Okta and confirmed app access ended in the same session cycle, and documented the SCIM provisioning concept this maps to when the app supports it: create, update, and deactivate pushed from the identity provider instead of edited app by app.
6. Wrote the SAML flow in plain language for the lab notes: user requests app, identity provider authenticates, assertion issued, app creates the session. If I cannot explain the flow, I do not claim the integration.

Validation
| ID | Case | Expected | Result |
|---|---|---|---|
| IAM4-01 | Group member signs into assigned app via SSO | Lands in app, no second password | Pass |
| IAM4-02 | Non group user attempts app | No app tile, direct link blocked | Pass |
| IAM4-03 | Sensitive app without MFA factor | Blocked at policy | Pass |
| IAM4-04 | Deactivated user attempts sign in | Blocked at Okta, app session ends | Pass |
| IAM4-05 | Reactivated user | Access restored by group, no manual app edits | Pass |

Deliverables in this lab
- Okta org build notes, users, groups, app, policy
- SSO flow explanation in plain language
- Leaver runbook: deactivate once, verify everywhere

What this proves
Okta administration fundamentals, SSO integration, group based assignment, MFA policy, and lifecycle thinking, built and tested hands on. This lab is also my study base for the Okta Certified Professional path.

## IAM Lab 5: Active Directory to Cloud IdP, Tiered Forest, ADFS, Entra Sync, Federation Migration

Label: Lab environment only. Build package completed 2026-10-27 from IAM Ryan's 10-step homelab roadmap, adapted to this plan. The Windows Server execution runs on Cordon's own machine and the tenant steps under his own accounts; neither Active Directory, ADFS, nor Entra Connect is prior employer experience.

Business problem
A small healthcare company runs one flat directory: admins on daily accounts, a leaver still enabled, app sign-on handled app by app. The fix is built in analyst order: structure, tiered administration, lifecycle discipline, federation, hybrid sync, then a staged migration of app federation from ADFS to the cloud IdP.

What was built (package: goals/break-into-iam-in-4-months/files/lab5-ad-to-cloud-idp/)
- Directory model for fictional Meridian Health (meridianlab.local): 12 OUs in a three-tier layout, 8 security groups, 13 accounts including separate adm- accounts and a disabled leaver parked in a Disabled OU.
- Five ready-to-run PowerShell scripts: forest install, OU creation, user import from CSV, group creation and membership, and live verification queries.
- A full runbook covering all 10 roadmap steps: VirtualBox and Windows Server 2025 Evaluation, AD DS promotion, ADFS with a Salesforce developer org federation, Entra Connect Sync OU-filtered to the People OU only, and the Salesforce federation migration to Entra piloted on a 3-user group with a written rollback.
- A model validation harness (Python) that checks the design data the scripts execute: tier purity, admin account placement, leaver handling, department isolation, naming convention, pilot group composition.

Validation (executed 2026-10-27, model layer)
| ID | Case | Expected | Result |
|---|---|---|---|
| M-02 | Tier0-Admins membership | Admin accounts only | Pass |
| M-04 | Leaver account state | Disabled, in Disabled OU, no groups | Pass |
| M-06 | Department group membership | No cross-department access | Pass |
| M-09 | Salesforce pilot group | 3+ members across 2+ departments | Pass |

Full log: 9 of 9 checks passed, saved with the package. Ten live-build validation cases (AD-01 to AD-10) are written in the runbook and fill in when the Windows build runs.

What this proves
Active Directory design judgment (tiering, separation of admin and daily accounts, leaver discipline) plus the hybrid identity storyline employers ask about: ADFS federation, scoped directory sync, and a piloted federation migration with rollback. Design and scripts are complete and verified at the model layer; live execution evidence is added when the build runs.

---

Roadmap note for the portfolio
Next IAM labs already planned: SAML SSO in Entra, Conditional Access baseline policies, SCIM provisioning end to end, access reviews and entitlement cleanup, and a PowerShell and Microsoft Graph automation runbook. Each will be added here with the same ticket style documentation.
