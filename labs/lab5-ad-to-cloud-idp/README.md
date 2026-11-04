# IAM Lab 5: Active Directory to Cloud IdP

Built 2026-10-27 from the 10-step homelab roadmap posted by IAM Ryan (@TheImmaturedad), adapted to Cordon's IAM plan. Fictional company: Meridian Health. Domain: meridianlab.local. Total cost: $0 (evaluation and free tiers only).

## Status, stated plainly

- **Completed by Merlin (2026-10-27):** the full design and build package. Directory model (12 OUs, 8 groups, 13 accounts) specified in `data/`, five ready-to-run PowerShell scripts in `scripts/`, and a model validation harness that was actually executed: **9 of 9 checks passed** (log in `validation/validation-log.txt`).
- **Runs on Cordon's machine:** the Windows Server build itself. Merlin's workspace has no virtualization support and about 2 GB of free RAM, so a Windows Server VM cannot run here. The VM runs in VirtualBox on Cordon's own Windows PC (about 60 to 90 minutes, mostly waiting on installs).
- **Runs under Cordon's own accounts:** the Salesforce developer org, the Entra tenant, and the sync agent sign-ins. Those are his signups, the same as his GitHub and tenant setup from Month 1.
- **Honesty label:** lab environment only. This is not employer experience with Active Directory, ADFS, or Entra Connect, and it is written that way everywhere it appears.

## Business problem

A small healthcare company runs everything from one flat directory: every account in the default Users container, admins using their daily accounts, a leaver still enabled months later, and app sign-on handled app by app. The lab builds the fix in the order an IAM analyst would: structure first, tiered administration, lifecycle discipline, then federation, then hybrid sync, then a staged migration of the app federation from on-prem ADFS to the cloud IdP.

## Architecture

- One VirtualBox VM: Windows Server 2025 Evaluation (180 days, free from the Microsoft Evaluation Center), 2 vCPU, 4 GB RAM, 60 GB disk, host-only or NAT networking.
- AD DS forest `meridianlab.local`, one domain controller (lab only; production would never stop at one).
- Tiered OU model under `OU=Meridian`: Tier0-Admin, Tier1-Servers, Tier2-Workstations, People (Clinical, Revenue Cycle, IT, HR), Groups, Service Accounts, Disabled.
- ADFS on the same server (acceptable in a lab, never in production) federating a free Salesforce developer org.
- Microsoft Entra tenant with Entra Connect Sync, OU-filtered to the People OU only, password hash sync and Seamless SSO.
- End state: Salesforce federation migrated from ADFS to Entra, piloted on the `GG_Salesforce_Users` group, with a written rollback.

## The 10 steps

**Step 1: VirtualBox.** Install VirtualBox on your Windows PC (free, virtualbox.org). Create VM `LAB-DC01`: Windows Server 2025 (64-bit), 2 vCPU, 4096 MB RAM, 60 GB dynamically allocated disk. Attach the Server 2025 Evaluation ISO from the Microsoft Evaluation Center and install **Windows Server 2025 Datacenter Evaluation (Desktop Experience)**. Set a strong local Administrator password and run Windows Update once.

**Step 2: Windows Server baseline.** Rename the server `LAB-DC01` (Server Manager, Local Server, Computer name). Set a static IP on the host-only adapter if you use one. Snapshot the VM in VirtualBox and name it `clean-install`. Every later mistake costs minutes instead of a rebuild because of this snapshot.

**Step 3: Active Directory.** Open elevated PowerShell and run `scripts/01-Install-ADDSForest.ps1`. It installs the AD DS role and promotes the server to the first domain controller of `meridianlab.local`, with DNS. The server reboots. Sign in as `MERIDIAN\Administrator`.

**Step 4: ADFS (deferred on purpose).** ADFS is installed at Step 7, after the directory exists, because a federation service with nothing to federate proves nothing. Note for interviews: Microsoft positions Entra ID as the federation future and ADFS as legacy. This lab still builds ADFS once, because thousands of companies still run it and migration work starts from it. That is the entire point of Steps 7 and 10.

**Step 5: Tiered OU structure.** Run `scripts/02-Create-OU-Structure.ps1`. It creates all 12 OUs from `data/ou-model.json`, protected from accidental deletion. The tiering logic: Tier 0 is the identity control plane (domain controllers, admin accounts), Tier 1 is servers, Tier 2 is workstations and people. Admin accounts never live with daily-use accounts.

**Step 6: OUs, groups, users.** Run `scripts/03-Import-LabUsers.ps1`, then `scripts/04-Create-Groups-And-Membership.ps1`. Result: 13 accounts (10 enabled users, 1 disabled leaver parked in the Disabled OU, 2 separate `adm-` accounts in Tier0-Admin), 8 security groups, department isolation enforced. Then run `scripts/05-Verify-Lab.ps1` and compare its output against `validation/validation-log.txt`. The live queries and the model checks are the same nine checks at two layers.

**Step 7: Salesforce dev org federated to ADFS.** Sign up for a free Salesforce Developer Edition org (developer.salesforce.com). On LAB-DC01, install the ADFS role (`Install-WindowsFeature ADFS-Federation -IncludeManagementTools`) and run the ADFS configuration wizard with a self-signed certificate for `fs.meridianlab.local` (lab only). In ADFS, add Salesforce as a relying party trust using Salesforce's SAML metadata, with claim rules issuing NameID and email from AD attributes. In Salesforce: Setup, Single Sign-On Settings, enable SAML, create a SAML SSO configuration from the ADFS metadata, then set the domain under My Domain so the SSO path is tested. Validate: a pilot user (`jrivera`) signs in through ADFS. What breaks first is almost always the NameID format or a clock skew; both are documented findings, write them down.

**Step 8: Cloud IdP.** Use your Month 1 Entra tenant (add Okta instead only if you want a second run of the same pattern; the sync in Step 9 is an Entra feature, so Entra is the primary here). Confirm the tenant domain and one Global Admin sign-in works, and that MFA is on for your admin account.

**Step 9: Entra Connect Sync.** Download Microsoft Entra Connect from the Entra admin center (Identity, Hybrid management, Microsoft Entra Connect). Install it on LAB-DC01 (lab placement; production puts it on a member server, never a DC). Choose **customize**, then: password hash synchronization, OU filtering scoped to **People OU only** (admin accounts, service accounts, and the Disabled OU never sync), and enable Seamless SSO. Run the first sync, then force a delta after a change with `Start-ADSyncSyncCycle -PolicyType Delta`. Validate in the Entra admin center: the 10 People users appear as "Windows Server AD" sourced, the 2 `adm-` accounts and the leaver do not appear at all. Current product note: Microsoft now prefers **Entra Cloud Sync** for new simple deployments; Connect Sync is taught here because it matches the roadmap, the SC-300 curriculum, and the ADFS coexistence this lab needs.

**Step 10: Migrate Salesforce from ADFS to Entra.** In the Entra admin center, Enterprise applications, add **Salesforce** from the gallery. Configure SAML SSO (identifier, reply URL, NameID = user.userprincipalname), assign only `GG_Salesforce_Users` (the pilot: jrivera, kosei, swhitfield), and have each pilot user test through myapps.microsoft.com while the ADFS path is still live. Then in Salesforce SSO settings, point the SAML configuration at the Entra metadata for the pilot, validate pilot sign-ins, and expand assignment to all Salesforce users. **Rollback:** Salesforce keeps both SSO configurations; if anything fails, re-select the ADFS configuration and the pilot is back on the old path in minutes. Decommission note: ADFS stays running in the lab for study, with a written note that production migration ends with ADFS powered off for a full password cycle before removal.

## Validation test cases for the live build

| ID | Case | Expected | Maps to |
|---|---|---|---|
| AD-01 | Standard user signs in to LAB-DC01 console | Blocked or standard session only, no admin tools | M-02 |
| AD-02 | adm-phaddad signs in and opens ADUC | Full administration works | M-03 |
| AD-03 | Leaver account sign-in attempt | Blocked, account disabled | M-04 |
| AD-04 | jrivera attempts a Revenue Cycle group resource | Access denied, department isolation holds | M-06 |
| AD-05 | Salesforce sign-in as jrivera via ADFS | Lands in Salesforce, no second password prompt after AD sign-in | Step 7 |
| AD-06 | After first Entra sync, check tenant user list | Exactly the 10 People users, sourced from Windows Server AD | Step 9 |
| AD-07 | adm- accounts and leaver checked in Entra | Absent (OU filtering held) | Step 9 |
| AD-08 | Change tnguyen's title in AD, force delta sync | New title appears in Entra within one cycle | Step 9 |
| AD-09 | Pilot Salesforce sign-in via Entra | Success for the 3 pilot users; non-pilot user is blocked | Step 10 |
| AD-10 | Rollback drill: re-select ADFS SSO in Salesforce | Pilot sign-in works on the ADFS path again | Step 10 |

Record actual results in this table as you run it. A filled table with one documented failure and its fix is worth more in an interview than 10 clean passes.

## Evidence checklist (what to capture)

- Screenshot: ADUC showing the tiered OU tree expanded.
- Output of `scripts/05-Verify-Lab.ps1` saved to a text file.
- Screenshot: Entra admin center user list showing sync source.
- Screenshot: Salesforce SSO settings page (either configuration) with your domain.
- The filled validation table above, including anything that broke and the fix.

## What this proves, in interview language

"I built a tiered Active Directory forest from scratch, enforced admin account separation, modeled a leaver the way an auditor wants to find one, federated Salesforce to ADFS, synced a scoped slice of the directory to Entra with OU filtering, and migrated the app federation to Entra with a pilot group and a rollback plan." Every clause of that sentence maps to a step and a validation case in this package.

## Files in this package

- `data/ou-model.json` and `data/lab-users.csv`: the directory design, executed by the scripts and checked by the validator.
- `scripts/01` to `05`: forest install, OUs, users, groups and membership, live verification queries.
- `validation/validate_model.py` and `validation-log.txt`: the model checks, 9 of 9 passed on 2026-10-27.
