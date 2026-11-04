# IAM Lab 5 - Step 6: create every account in data\lab-users.csv.
# Idempotent: existing accounts are skipped. The lab password below is a
# THROWAWAY for an isolated lab VM only; users must change it at first logon.
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
Start-Transcript -Path "$PSScriptRoot\03-users.log" -Append

$labPassword = ConvertTo-SecureString 'Lab-Only!2026-ChangeMe' -AsPlainText -Force
$users = Import-Csv "$PSScriptRoot\..\data\lab-users.csv"

foreach ($u in $users) {
    if (Get-ADUser -Identity $u.SamAccountName -ErrorAction SilentlyContinue) {
        Write-Host "exists: $($u.SamAccountName)"
        continue
    }
    New-ADUser -SamAccountName $u.SamAccountName `
        -UserPrincipalName "$($u.SamAccountName)@meridianlab.local" `
        -GivenName $u.GivenName -Surname $u.Surname -DisplayName $u.DisplayName `
        -Name $u.DisplayName -Department $u.Department -Title $u.Title `
        -Path $u.OU -AccountPassword $labPassword `
        -Enabled ($u.Enabled -eq 'TRUE') -ChangePasswordAtLogon $true
    Write-Host "created: $($u.SamAccountName) in $($u.OU)"
}
Stop-Transcript
