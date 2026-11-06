#!/usr/bin/env python3
"""IAM Lab 6 - mover transition model validation harness.

Runs real checks against the lab's design data (data/mover-model.json and
data/access-transition-matrix.csv): the same account, groups, and entitlement
mapping the PowerShell scripts act on in Active Directory. It computes the
mover's effective access before and after the transfer from group membership
alone, and asserts the lose / gain sets are exactly what the exercise asks
for. It also reproduces the add-only mistake on the model and confirms the
residual-access check catches it. This validates the DESIGN layer. It does
not claim a Windows Server ran the move; the live execution steps live in
the lab README.
"""
import csv, json, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "..", "data")

model = json.load(open(os.path.join(DATA, "mover-model.json")))
matrix = list(csv.DictReader(open(os.path.join(DATA, "access-transition-matrix.csv"))))

groups = model["groups"]
mover = model["mover"]
expected = model["expected"]

def entitlements(group_names):
    out = set()
    for g in group_names:
        out |= set(groups[g]["entitlements"])
    return out

before = entitlements(mover["from"]["groups"])
after = entitlements(mover["to"]["groups"])
exp_lose = set(expected["lose"])
exp_gain = set(expected["gain"])
exp_keep = set(expected["keep_entitlements"])

results = []
def check(cid, name, ok, detail):
    results.append((cid, name, ok, detail))

# 1. Model integrity: every group the mover references exists and carries entitlements
referenced = set(mover["from"]["groups"]) | set(mover["to"]["groups"])
bad = [g for g in referenced if g not in groups or not groups[g].get("entitlements")]
check("T-01", "Every referenced group exists in the model with entitlements defined", not bad,
      f"{len(referenced)} groups referenced; problems: {bad or 'none'}")

# 2. Before state: effective access computed from group membership matches the declared expectation
check("T-02", "Before access is exactly the old department entitlements plus any kept entitlements",
      before == exp_lose | exp_keep,
      f"computed before: {len(before)} entitlements; expected: {len(exp_lose | exp_keep)}")

# 3. After state: effective access is exactly the new department entitlements plus kept ones
check("T-03", "After access is exactly the new department entitlements plus any kept entitlements",
      after == exp_gain | exp_keep,
      f"computed after: {len(after)} entitlements; expected: {len(exp_gain | exp_keep)}")

# 4. Lose and gain sets: the diff of before and after is exactly the declared answer
check("T-04", "Lose set and gain set match the declared transition exactly",
      (before - after) == exp_lose and (after - before) == exp_gain,
      f"lose: {sorted(before - after)}; gain: {sorted(after - before)}")

# 5. No residual access: nothing sourced from an old-department group survives the move
old_dept_ent = set()
for gname, g in groups.items():
    if g.get("department") == mover["from"]["department"]:
        old_dept_ent |= set(g["entitlements"])
residual_groups = [g for g in mover["to"]["groups"] if g in mover["from"]["groups"] and g not in mover["to"]["groups"]]
check("T-05", "No residual old-department entitlements or groups after the move",
      not (after & old_dept_ent) and not residual_groups,
      f"residual entitlements: {sorted(after & old_dept_ent) or 'none'}; residual groups: {residual_groups or 'none'}")

# 6. The human-readable transition matrix agrees with the computed model
m_before = {r["Entitlement"] for r in matrix if r["Before"] == "Yes"}
m_after = {r["Entitlement"] for r in matrix if r["After"] == "Yes"}
m_lose = {r["Entitlement"] for r in matrix if r["Verdict"].startswith("Lose")}
m_gain = {r["Entitlement"] for r in matrix if r["Verdict"].startswith("Gain")}
check("T-06", "Access transition matrix matches the computed before / after / lose / gain sets",
      m_before == before and m_after == after and m_lose == exp_lose and m_gain == exp_gain,
      f"matrix rows: {len(matrix)}; before/after/lose/gain all consistent: "
      f"{m_before == before and m_after == after and m_lose == exp_lose and m_gain == exp_gain}")

# 7. The add-only mistake is reproduced on the model, and the residual check catches it
naive_groups = list(dict.fromkeys(mover["from"]["groups"] + mover["to"]["groups"]))
naive_after = entitlements(naive_groups)
naive_residual = naive_after - after
check("T-07", "Add-only move leaves residual access, and the residual check flags all of it",
      naive_residual == exp_lose,
      f"naive move keeps {len(naive_residual)} entitlements that should have been lost: {sorted(naive_residual)}")

# 8. Identity continuity: one account, still enabled; only OU, department, title, and groups change
same_account = mover["from"]["ou"] != mover["to"]["ou"] and \
    mover["from"]["department"] != mover["to"]["department"] and \
    mover["from"]["title"] != mover["to"]["title"]
check("T-08", "Identity persists across the move: account unchanged and enabled, OU/department/title change",
      same_account and mover["enabled"] is True and len(expected["keep_identity"]) >= 3,
      f"account: {mover['sam_account_name']}; enabled: {mover['enabled']}; "
      f"kept identity facts declared: {len(expected['keep_identity'])}")

print("IAM LAB 6 - MODEL VALIDATION LOG")
print(f"Model: {model['company']} / {model['domain']} / mover {mover['sam_account_name']} "
      f"({mover['from']['department']} -> {mover['to']['department']})")
print("-" * 78)
failed = 0
for cid, name, ok, detail in results:
    print(f"[{'PASS' if ok else 'FAIL'}] {cid} {name}")
    print(f"       {detail}")
    failed += 0 if ok else 1
print("-" * 78)
print(f"Result: {len(results) - failed}/{len(results)} checks passed")
sys.exit(1 if failed else 0)
