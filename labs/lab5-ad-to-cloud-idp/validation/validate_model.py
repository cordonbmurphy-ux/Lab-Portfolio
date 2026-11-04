#!/usr/bin/env python3
"""IAM Lab 5 - directory model validation harness.

Runs real checks against the lab's design data (data/ou-model.json and
data/lab-users.csv): the same OU paths, groups, and accounts the PowerShell
scripts create in Active Directory. A check that fails here would fail as a
finding in the live AD build, so the model is fixed before anyone touches a
server. This validates the DESIGN layer. It does not claim a Windows Server
was built; the live execution checklist lives in the lab README.
"""
import csv, json, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "..", "data")

model = json.load(open(os.path.join(DATA, "ou-model.json")))
users = list(csv.DictReader(open(os.path.join(DATA, "lab-users.csv"))))

ous = set(model["ous"])
groups = {g["name"]: g for g in model["groups"]}
dept_group_prefix = {"Clinical": "GG_Clinical", "Revenue Cycle": "GG_Revenue", "IT": "GG_IT", "HR": "GG_HR"}
cross_dept_allowed = {"GG_VPN_Access", "GG_Salesforce_Users", "Tier1-ServerOps", "Tier0-Admins"}

results = []
def check(cid, name, ok, detail):
    results.append((cid, name, ok, detail))

# 1. Every user's OU exists in the model
bad = [u["SamAccountName"] for u in users if u["OU"] not in ous]
check("M-01", "Every account sits in an OU that exists in the model", not bad,
      f"{len(users)} accounts checked; bad OU paths: {bad or 'none'}")

# 2. Tier 0 purity: no daily-use account in Tier0-Admins
bad = [u["SamAccountName"] for u in users
       if "Tier0-Admins" in u["Groups"] and u["AccountType"] != "Admin"]
check("M-02", "Tier0-Admins contains admin accounts only", not bad,
      f"daily-use accounts in Tier0-Admins: {bad or 'none'}")

# 3. Admin accounts live only in the Tier0-Admin OU
bad = [u["SamAccountName"] for u in users
       if u["AccountType"] == "Admin" and not u["OU"].startswith("OU=Tier0-Admin,")]
check("M-03", "Admin accounts live only in the Tier0-Admin OU", not bad,
      f"admin accounts outside Tier0-Admin OU: {bad or 'none'}")

# 4. Leaver handling: disabled and parked in the Disabled OU, no group access
leavers = [u for u in users if "leaver" in u["Title"].lower()]
ok = all(u["Enabled"] == "FALSE" and u["OU"].startswith("OU=Disabled,") and u["Groups"] == "" for u in leavers)
check("M-04", "Leaver is disabled, moved to Disabled OU, group access removed", ok and len(leavers) == 1,
      f"leaver rows: {[u['SamAccountName'] for u in leavers]}")

# 5. Every group a user references exists in the model
referenced = {g for u in users for g in u["Groups"].split(";") if g}
missing = referenced - set(groups)
check("M-05", "Every referenced group exists in the model", not missing,
      f"{len(referenced)} groups referenced; missing: {sorted(missing) or 'none'}")

# 6. Department isolation: a user's department group matches their department
bad = []
for u in users:
    if u["AccountType"] != "User" or u["Enabled"] != "TRUE":
        continue
    for g in u["Groups"].split(";"):
        if g.startswith("GG_") and g not in cross_dept_allowed and not g.startswith(dept_group_prefix[u["Department"]]):
            bad.append(f"{u['SamAccountName']} in {g}")
check("M-06", "Department groups never cross departments", not bad,
      f"cross-department memberships: {bad or 'none'}")

# 7. Naming convention: first initial + surname, lowercase (adm- prefix for admin accounts)
bad = []
for u in users:
    expected = (u["GivenName"][0] + u["Surname"]).lower().replace(" ", "")
    if u["AccountType"] == "Admin":
        expected = "adm-" + (u["GivenName"][0] + u["Surname"]).lower()
    if u["SamAccountName"] != expected:
        bad.append(f"{u['SamAccountName']} (expected {expected})")
check("M-07", "Account naming convention holds", not bad, f"violations: {bad or 'none'}")

# 8. Every department OU has at least one enabled user
dept_ous = {"Clinical": "OU=Clinical,", "Revenue Cycle": "OU=Revenue Cycle,", "IT": "OU=IT,", "HR": "OU=HR,"}
bad = [d for d, prefix in dept_ous.items()
       if not any(u["OU"].startswith(prefix) and u["Enabled"] == "TRUE" and u["AccountType"] == "User" for u in users)]
check("M-08", "Every department OU has at least one enabled user", not bad,
      f"departments with no enabled user: {bad or 'none'}")

# 9. Staged-rollout pilot group exists and has members from more than one department
pilot = [u for u in users if "GG_Salesforce_Users" in u["Groups"]]
depts = {u["Department"] for u in pilot}
check("M-09", "Salesforce pilot group exists for the ADFS to Entra staged migration",
      len(pilot) >= 3 and len(depts) >= 2,
      f"pilot members: {len(pilot)} across departments: {sorted(depts)}")

print("IAM LAB 5 - MODEL VALIDATION LOG")
print(f"Model: {model['company']} / {model['domain']} / {len(model['ous'])} OUs / {len(groups)} groups / {len(users)} accounts")
print("-" * 78)
failed = 0
for cid, name, ok, detail in results:
    print(f"[{'PASS' if ok else 'FAIL'}] {cid} {name}")
    print(f"       {detail}")
    failed += 0 if ok else 1
print("-" * 78)
print(f"Result: {len(results) - failed}/{len(results)} checks passed")
sys.exit(1 if failed else 0)
