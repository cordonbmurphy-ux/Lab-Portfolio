# IAM Lab 6 - Step 3: verify the transition against data\mover-model.json.
# Fails loudly (throw) if any check fails: old department access still present
# is a finding, not a warning. Prints the lose / gain summary an analyst would
# paste into the change ticket.
param(
    [string]$SamAccountName = 'mdoyle'
)
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
Start-Transcript -Path "$PSScriptRoot\03-verify-$SamAccountName.log" -Append

$model = Get-Content "$PSScriptRoot\..\data\mover-model.json" -Raw | ConvertFrom-Json
$mover = $model.mover
$failures = 0
function Report([string]$id, [string]$name, [bool]$ok, [string]$detail) {
    Write-Host "[$(if ($ok) { 'PASS' } else { 'FAIL' })] $id $name"
    Write-Host "       $detail"
    if (-not $ok) { $script:failures++ }
}

$u = Get-ADUser -Identity $SamAccountName -Properties Department, Title, Enabled, DistinguishedName
$groups = Get-ADPrincipalGroupMembership -Identity $SamAccountName | Select-Object -ExpandProperty Name
$ou = $u.DistinguishedName -replace '^CN=[^,]+,', ''

Report 'V-01' 'Account now lives in the target OU' ($ou -eq $mover.to.ou) "OU is $ou"
Report 'V-02' 'Department and Title updated' ($u.Department -eq $mover.to.department -and $u.Title -eq $mover.to.title) "Department=$($u.Department), Title=$($u.Title)"
$residual = $groups | Where-Object { $_ -in $mover.from.groups -and $_ -notin $mover.to.groups }
Report 'V-03' 'No residual access from the old department' ($residual.Count -eq 0) "residual groups: $(if ($residual) { $residual -join ', ' } else { 'none' })"
$missing = $mover.to.groups | Where-Object { $_ -notin $groups }
Report 'V-04' 'All target groups present' ($missing.Count -eq 0) "missing groups: $(if ($missing) { $missing -join ', ' } else { 'none' })"
Report 'V-05' 'Account still enabled (a mover is not a leaver)' ($u.Enabled -eq $true) "Enabled=$($u.Enabled)"

$lose = $mover.from.groups | Where-Object { $_ -notin $mover.to.groups } | ForEach-Object { $model.groups.$_.entitlements }
$gain = $mover.to.groups | Where-Object { $_ -notin $mover.from.groups } | ForEach-Object { $model.groups.$_.entitlements }
Write-Host "LOSE: $($lose -join '; ')"
Write-Host "GAIN: $($gain -join '; ')"

Stop-Transcript
if ($failures -gt 0) { throw "$failures verification check(s) failed" }
Write-Host "All verification checks passed."
