# IAM Lab 6 - Step 1: snapshot the mover's current state BEFORE the move.
# Account properties plus group memberships, printed in a stable order so the
# before and after snapshots diff cleanly. Run this first; its transcript is
# half of the lab evidence.
param(
    [string]$SamAccountName = 'mdoyle'
)
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
Start-Transcript -Path "$PSScriptRoot\01-before-snapshot-$SamAccountName.log" -Append

$u = Get-ADUser -Identity $SamAccountName -Properties Department, Title, Enabled, DistinguishedName, EmailAddress
Write-Host "Account:        $($u.SamAccountName)"
Write-Host "Display name:   $($u.DisplayName)"
Write-Host "OU:             $($u.DistinguishedName -replace '^CN=[^,]+,', '')"
Write-Host "Department:     $($u.Department)"
Write-Host "Title:          $($u.Title)"
Write-Host "Enabled:        $($u.Enabled)"
Write-Host "Email:          $($u.EmailAddress)"
Write-Host "Group memberships:"
Get-ADPrincipalGroupMembership -Identity $SamAccountName |
    Sort-Object Name |
    ForEach-Object { Write-Host "  - $($_.Name)" }
Stop-Transcript
