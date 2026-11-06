# IAM Lab 6 - Step 2: perform the department transfer from data\mover-model.json.
# Order is deliberate and is the point of the lab:
#   1. remove every current group the target state does not keep
#   2. add the target groups
#   3. move the object to the target OU and update Department and Title
# The account is never disabled, deleted, or recreated: identity persists,
# entitlements change. Supports -WhatIf for a dry run.
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$SamAccountName = 'mdoyle'
)
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
Start-Transcript -Path "$PSScriptRoot\02-move-$SamAccountName.log" -Append

$model = Get-Content "$PSScriptRoot\..\data\mover-model.json" -Raw | ConvertFrom-Json
$mover = $model.mover
if ($mover.sam_account_name -ne $SamAccountName) {
    throw "mover-model.json describes $($mover.sam_account_name), not $SamAccountName. Refusing to move the wrong account."
}

# Safety checks: everything the move touches must exist first.
$u = Get-ADUser -Identity $SamAccountName -Properties Department, Title, DistinguishedName
if (-not (Get-ADOrganizationalUnit -Identity $mover.to.ou -ErrorAction SilentlyContinue)) {
    throw "Target OU does not exist: $($mover.to.ou)"
}
foreach ($g in @($mover.from.groups) + @($mover.to.groups)) {
    if (-not (Get-ADGroup -Identity $g -ErrorAction SilentlyContinue)) {
        throw "Group does not exist: $g"
    }
}

$current = Get-ADPrincipalGroupMembership -Identity $SamAccountName | Select-Object -ExpandProperty Name
$toRemove = $current | Where-Object { $_ -in $mover.from.groups -and $_ -notin $mover.to.groups }
$toAdd = $mover.to.groups | Where-Object { $_ -notin $current }

foreach ($g in $toRemove) {
    if ($PSCmdlet.ShouldProcess($SamAccountName, "Remove from group $g")) {
        Remove-ADGroupMember -Identity $g -Members $SamAccountName -Confirm:$false
        Write-Host "removed: $SamAccountName from $g"
    }
}
foreach ($g in $toAdd) {
    if ($PSCmdlet.ShouldProcess($SamAccountName, "Add to group $g")) {
        Add-ADGroupMember -Identity $g -Members $SamAccountName
        Write-Host "added:   $SamAccountName to $g"
    }
}

if ($PSCmdlet.ShouldProcess($SamAccountName, "Move to $($mover.to.ou), set Department=$($mover.to.department), Title=$($mover.to.title)")) {
    Move-ADObject -Identity $u.DistinguishedName -TargetPath $mover.to.ou
    Set-ADUser -Identity $SamAccountName -Department $mover.to.department -Title $mover.to.title
    Write-Host "moved:   $SamAccountName to $($mover.to.ou)"
    Write-Host "updated: Department=$($mover.to.department), Title=$($mover.to.title)"
}
Write-Host "Account left enabled and intact: a move changes entitlements, not identity."
Stop-Transcript
